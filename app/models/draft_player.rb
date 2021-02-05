# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class DraftPlayer < ApplicationRecord
  belongs_to :team, optional: true
  belongs_to :original_team, :class_name => 'Team',  optional: true
  has_many :rosters
  has_many :draft_rankings
  has_one :draft_pick
  has_many :wanteds
  has_many :wantedowners, :through => :wanteds, :source => :owner

  # list filters
  ALL_PLAYERS = 'all'
  DRAFTED_PLAYERS = 'drafted'
  NOTDRAFTED_PLAYERS = 'notdrafted'
  ME_ME_ME = 'notdrafted+mine'

  # new draftstatus
  DRAFT_STATUS_TEAMED = 1
  DRAFT_STATUS_NOTDRAFTED = 2
  DRAFT_STATUS_DRAFTED = 3


  paginates_per 50

  scope :byrankingvalues, lambda {|rv1,rv2|
    select("#{self.table_name}.*, draft_rankings.value as rankvalue")
    .joins(:draft_rankings)
    .where("draft_rankings.ranking_value_id IN (#{rv1.id},#{rv2.id})")
    .order("rankvalue DESC")
  }

  scope :teamed, lambda { where(:draftstatus => DRAFT_STATUS_TEAMED) }
  scope :notdrafted, lambda { where(:draftstatus => DRAFT_STATUS_NOTDRAFTED) }
  scope :drafted, lambda { where(:draftstatus => DRAFT_STATUS_DRAFTED) }
  scope :draft_eligible, lambda { where(["draftstatus IN (#{DRAFT_STATUS_DRAFTED}, #{DRAFT_STATUS_NOTDRAFTED})"]) }
  scope :rostered, lambda { where(["draftstatus IN (#{DRAFT_STATUS_DRAFTED}, #{DRAFT_STATUS_TEAMED})"]) }
  scope :not_injured, lambda { where("position != 'INJ'") }

  scope :byteam, lambda {|team| where(team_id: team.id)}

  scope :draftstatus, lambda {|draftstatus,team|
    case draftstatus
    when DRAFTED_PLAYERS
      where("team_id != 0")
    when NOTDRAFTED_PLAYERS
      where("team_id = 0")
    when ALL_PLAYERS
      where("team_id = 0 or team_id != 0")
    else
      if(team.blank?)
        where("team_id = 0")
      else
        where("team_id = 0 or team_id = #{team.id}")
      end
    end
  }

  scope :byposition, lambda {|position| where(position: position.upcase)}


  def self.rebuild_from_statlines
    self.dump_data

    # Pitchers
    DraftPitchingStatline.order('lastname,firstname asc').each do |pitcherstat|

      pitcher = Pitcher.create(:firstname => pitcherstat.firstname,
                    :lastname => pitcherstat.lastname,
                    :position => pitcherstat.position,
                    :age => pitcherstat.age,
                    :statline_id => pitcherstat.id,
                    :team_id => pitcherstat.team_id,
                    :draftstatus => (team_id == Team::NO_TEAM) ? DraftPlayer::DRAFT_STATUS_NOTDRAFTED : DraftPlayer::DRAFT_STATUS_TEAMED)
    end

    # Batters
    DraftBattingStatline.order('lastname,firstname asc').each do |batterstat|

      batter = Batter.create(:firstname => batterstat.firstname,
                    :lastname => batterstat.lastname,
                    :position => batterstat.position,
                    :age => batterstat.age,
                    :statline_id => batterstat.id,
                    :team_id => team_id,
                    :draftstatus => (team_id == Team::NO_TEAM) ? DraftPlayer::DRAFT_STATUS_NOTDRAFTED : DraftPlayer::DRAFT_STATUS_TEAMED)
    end

    # rebuild rankings
    DraftRankingValue.rebuild
  end

  def self.sorting(*ranking_values)
    if(ranking_values.length == 0)
      order("lastname ASC")
    else
      select("#{self.table_name}.*, draft_rankings.value as rankvalue")
      .joins(:draft_rankings)
      .where("draft_rankings.ranking_value_id IN (#{ranking_values.map(&:id).join(',')})")
      .order("rankvalue DESC")
    end
  end

  def self.positionlabel(position)
    downcased = position.downcase
    case downcased
    when 'all'
      'All Players'
    when 'allbatters'
      'All Batters'
    when 'of'
      'All Outfielders'
    else
      if(Pitcher::POSITIONS[downcased])
        Pitcher::POSITIONS[downcased]
      elsif(Batter::POSITIONS[downcased])
        Batter::POSITIONS[downcased]
      else
        'Unknown'
      end
    end
  end

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def initials
    "#{self.firstname.first}#{self.lastname.first}"
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
      dp = DraftPick.where(player_id: self.id).first
      dp.update_attributes({:player_id =>  DraftPick::NOPICK})
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
      pick.update_attributes({:player_id => self.id, :team_id => team.id})
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
    # use of "rlike" also allows for regexp matching - cool eh?
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
      conditions = ["((firstname rlike :firstword AND lastname rlike :secondword) OR (firstname rlike :secondword AND lastname rlike :firstword))",findvalues]
    else
      findvalues = {
        :findfirst => searchterm,
        :findlast => searchterm
      }
      conditions = ["(firstname rlike :findfirst OR lastname rlike :findlast)",findvalues]
    end

    where(conditions)
  end

  def self.rankingvalues(ranking_value)
    self.byrankingvalue(ranking_value).map(&:rankvalue).map{|rv|rv*100}
  end

  def scaled_stats_by_rankingvalue(ranking_value)
    stats = {}
    playertype = (self.class == Pitcher) ? Stat::PITCHER : Stat::BATTER
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
end
