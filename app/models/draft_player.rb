# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPlayer < ApplicationRecord
  include CleanupTools

  belongs_to :team, optional: true
  belongs_to :original_team, :class_name => 'Team',  optional: true
  has_many :rosters
  has_many :draft_rankings
  has_one :draft_pick
  has_many :draft_wanteds
  has_many :wantedowners, :through => :draft_wanteds, :source => :owner
  has_many :draft_owner_ranks
  has_many :rankingowners, :through => :draft_owner_ranks, :source => :owner

  # player types
  PITCHER = 1
  BATTER = 2

  # positions
  PITCHING_POSITIONS = ['sp','rp']
  BATTING_POSITIONS = ['c','1b','2b','3b','ss','lf','cf','rf','dh']


  # list filters
  ALL_PLAYERS = 'all'
  DRAFTED_PLAYERS = 'drafted'
  NOTDRAFTED_PLAYERS = 'notdrafted'
  ME_ME_ME = 'notdrafted+mine'

  # new draftstatus
  DRAFT_STATUS_NOTDRAFTED = 2
  DRAFT_STATUS_DRAFTED = 3
  DRAFT_STATUS_TEAMED = 4


  paginates_per 50

  scope :teamed, lambda { where(:draftstatus => DRAFT_STATUS_TEAMED) }
  scope :notdrafted, lambda { where(:draftstatus => DRAFT_STATUS_NOTDRAFTED) }
  scope :drafted, lambda { where(:draftstatus => DRAFT_STATUS_DRAFTED) }
  scope :draft_eligible, lambda { where(["draftstatus IN (#{DRAFT_STATUS_DRAFTED}, #{DRAFT_STATUS_NOTDRAFTED})"]) }
  scope :rostered, lambda { where(["draftstatus IN (#{DRAFT_STATUS_DRAFTED}, #{DRAFT_STATUS_TEAMED})"]) }
  scope :not_injured, lambda { where("position != 'INJ'") }

  scope :byteam, lambda {|team| where(team_id: team.id)}

  scope :byposition, lambda {|position| where(position: position.downcase)}


  def self.rebuild_from_statlines
    self.dump_data

    # Pitchers
    DraftPitchingStatline.order('last_name,first_name asc').each do |pitcherstat|

      pitcher = DraftPitcher.create(:first_name => pitcherstat.first_name,
                    :last_name => pitcherstat.last_name,
                    :position => pitcherstat.position,
                    :age => pitcherstat.age,
                    :statline_id => pitcherstat.id,
                    :team_id => pitcherstat.team_id,
                    :draftstatus => (pitcherstat.team_id == Team::NO_TEAM) ? DraftPlayer::DRAFT_STATUS_NOTDRAFTED : DraftPlayer::DRAFT_STATUS_TEAMED)
    end

    # Batters
    DraftBattingStatline.order('last_name,first_name asc').each do |batterstat|

      batter = DraftBatter.create(:first_name => batterstat.first_name,
                    :last_name => batterstat.last_name,
                    :position => batterstat.position,
                    :age => batterstat.age,
                    :statline_id => batterstat.id,
                    :team_id => batterstat.team_id,
                    :draftstatus => (batterstat.team_id == Team::NO_TEAM) ? DraftPlayer::DRAFT_STATUS_NOTDRAFTED : DraftPlayer::DRAFT_STATUS_TEAMED)
    end

    # rebuild rankings
    DraftRankingValue.rebuild
  end


  def self.playerlist(owner:, draftstatus:, position:, owner_rank: false, ranking_values: [])
    # sorting
    if(ranking_values.length > 0)
      if(owner_rank)
        case position.downcase
        when 'all'
          query_column = 'overall'
        when 'default'
          query_column = 'overall'
        when 'allbatters'
          query_column = 'overall'
        when 'allpitchers'
          query_column = 'overall'
        when 'of'
          query_column = 'overall'
        else
          query_column = "pos_#{position.downcase}"
        end
        buildscope = self.select("#{self.table_name}.*, draft_rankings.value as rankvalue, draft_owner_ranks.#{query_column} as draft_owner_rankvalue")
        buildscope = buildscope.includes(:team)
        buildscope = buildscope.joins(:draft_rankings)
        buildscope = buildscope.joins(:draft_owner_ranks)
        buildscope = buildscope.where("draft_rankings.draft_ranking_value_id IN (#{ranking_values.map(&:id).join(',')})")
        buildscope = buildscope.where("draft_owner_ranks.owner_id = #{owner.id}")
        buildscope = buildscope.where("draft_owner_ranks.#{query_column} IS NOT NULL")
        buildscope = buildscope.order("draft_owner_rankvalue ASC")
        buildscope = buildscope.order("rankvalue DESC")
        buildscope = buildscope.order("#{self.table_name}.id ASC")
      else
        buildscope = self.select("#{self.table_name}.*, draft_rankings.value as rankvalue")
        buildscope = buildscope.includes(:team)
        buildscope = buildscope.joins(:draft_rankings)
        buildscope = buildscope.where("draft_rankings.draft_ranking_value_id IN (#{ranking_values.map(&:id).join(',')})")
        buildscope = buildscope.order("rankvalue DESC")
        buildscope = buildscope.order("#{self.table_name}.id ASC")
      end
    else
      buildscope = self.includes(:team)
      buildscope = buildscope.order("last_name ASC")
    end

    pitching_positions = PITCHING_POSITIONS
    batting_positions = BATTING_POSITIONS
    case position.downcase
    when *pitching_positions
      buildscope = buildscope.where("(#{self.table_name}.position = '#{position}')")
    when *batting_positions
      if(position.downcase == 'dh')
        buildscope = buildscope.where("(#{self.table_name}.position = '#{position}')")
      else
        ratingfield = DraftBattingStatline::RATINGFIELDS[position.downcase]
        buildscope = buildscope.joins(:statline)
        buildscope = buildscope.where("(draft_players.position = '#{position}' or draft_batting_statlines.#{ratingfield} != '')")
      end
    when 'of'
      buildscope = buildscope.joins(:statline)
      buildscope = buildscope.where("(draft_players.position IN ('cf','lf','rf') or draft_batting_statlines.pos_cf != '' or draft_batting_statlines.pos_lf != '' or draft_batting_statlines.pos_rf != '')")
    end

    case draftstatus
    when DRAFTED_PLAYERS
      buildscope = buildscope.where("#{self.table_name}.team_id != 0")
    when NOTDRAFTED_PLAYERS
      buildscope = buildscope.where("#{self.table_name}.team_id = 0")
    when ME_ME_ME
      filter_team = owner.team
      buildscope = buildscope.where("#{self.table_name}.team_id = 0 or #{self.table_name}.team_id = #{filter_team.id}")
    end

    buildscope
  end

  def self.positionlabel(position)
    downcased = position.downcase
    case downcased
    when 'all'
      'All Players'
    when 'allbatters'
      'All Batters'
    when 'allpitchers'
      'All Pitchers'
    when 'of'
      'All Outfielders'
    else
      if(DraftPitcher::POSITIONS[downcased])
        DraftPitcher::POSITIONS[downcased]
      elsif(DraftBatter::POSITIONS[downcased])
        DraftBatter::POSITIONS[downcased]
      else
        'Unknown'
      end
    end
  end

  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  def initials
    "#{self.first_name.first}#{self.last_name.first}"
  end

  def teamed?
    return (self.team_id != Team::NO_TEAM)
  end

  def drafted?
    return (!self.draft_pick.nil?)
  end

  def releaseplayer
    current_team_id = self.team_id
    self.update_attributes({:team_id => Team::NO_TEAM, :draftstatus => DRAFT_STATUS_NOTDRAFTED, :original_team_id => current_team_id})
  end

  def returntodraft
    return if(self.draftstatus != DRAFT_STATUS_DRAFTED)
    if(!self.draft_pick.nil?)
      dp = DraftPick.where(draft_player_id: self.id).first
      dp.update_attributes({:draft_player_id =>  DraftPick::NOPICK})
    end
    current_team = self.team
    self.update_attributes({:team_id => Team::NO_TEAM, :draftstatus => DRAFT_STATUS_NOTDRAFTED})
  end

  def draftplayer(options = {})
    pick = options[:draftpick] || DraftPick::CURRENTPICK
    team = options[:team] || nil

    return if(self.draftstatus != DRAFT_STATUS_NOTDRAFTED)
    pick = pick.to_i
    if(pick == DraftPick::CURRENTPICK)
      pick = DraftPick.current_pick
    end

    if(team.nil?)
      team = Team.find_by_draftpick(pick)
    end

    if(team)
      self.update_attributes({:team_id => team.id, :draftstatus => DRAFT_STATUS_DRAFTED})
      pick.update_attributes({:draft_player_id => self.id, :team_id => team.id})
    end
  end

  def positions
    if(self.class.name == 'Pitcher')
      return [self.position.downcase]
    else
      mystatline = self.statline
      returnpositions = []
      DraftBattingStatline::RATINGFIELDS.each do |pos,field|
        if(!mystatline.send(field).blank?)
          returnpositions << pos
        end
      end
      return returnpositions
    end
  end

  def self.searchplayers(searchterm)
    if searchterm.nil?
      return nil
    end
    # remove any leading * to avoid borking mysql
    # remove any '\' characters because it's WAAAAY too close to the return key
    searchterm = searchterm.gsub(/\\/,'').gsub(/^\*/,'$').strip
    # in the format wordone wordtwo?
    words = searchterm.split(%r{\s*,\s*|\s+})
    if(words.length > 1)
      findvalues = {
        :firstword => words[0],
        :secondword => words[1]
      }
      conditions = ["((first_name ~* :firstword AND last_name ~* :secondword) OR (first_name ~* :secondword AND last_name ~* :firstword))",findvalues]
    else
      findvalues = {
        :findfirst => searchterm,
        :findlast => searchterm
      }
      conditions = ["(first_name ~* :findfirst OR last_name ~* :findlast)",findvalues]
    end

    where(conditions)
  end

  def self.rankingvalues(ranking_value)
    self.byrankingvalue(ranking_value).map(&:rankvalue).map{|rv|rv*100}
  end

  def scaled_stats_by_rankingvalue(ranking_value)
    stats = {}
    playertype = (self.class == DraftPitcher) ? Stat::PITCHER : Stat::BATTER
    ranking_value.formula.each do |factor|
      column = factor[:column]
      stat = DraftStatDistribution.find_or_create(playertype,column)
      stats[column] = {}
      stats[column][:mine] = stat.scaled_distribution[:players][self.id] ? stat.scaled_distribution[:players][self.id] : 0
      stats[column][:max] = stat.scaled_distribution[:values].max
      stats[column][:min] = stat.scaled_distribution[:values].min
    end
    stats
  end

  def owner_rank_or_blank(owner)
    if(!(dor = self.draft_owner_ranks.where(owner: owner).first))
      dor = self.draft_owner_ranks.new(owner: owner)
    end
    dor
  end

end
