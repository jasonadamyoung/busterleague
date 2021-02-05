# encoding: utf-8
# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class Owner < ApplicationRecord

  has_many :teams
  has_many :players, :through => :teams
  has_many :draft_picks, :through => :teams
  has_many :ranking_values
  has_many :stat_preferences
  has_many :wanteds
  has_many :wantedplayers,-> { select("wanteds.highlight as highlight, players.*") }, :through => :wanteds, :source => :player
  belongs_to :primary_owner, :class_name => 'Owner'


  def fullname
    if(!self.first_name.blank? and !self.last_name.blank?)
      "#{self.first_name} #{self.last_name}"
    elsif(!self.nickname.blank?)
      self.nickname
    else
      'Anonymous'
    end
  end

  def login
    self.update_column(:last_login_at, Time.now.utc)
  end

  def team
    if(self.id == self.class.computer_id)
      Team.computer.order("RANDOM()").first
    elsif(self.teams.blank?)
      return nil
    else
      self.teams[0]
    end
  end


  def self.computer
    find(self.computer_id)
  end

  def self.computer_id
    1
  end

  def token
    randval = rand
    if(!(token = read_attribute(:token)))
      basetoken = Digest::SHA1.hexdigest(Settings.session_token+self.email+Time.now.to_s+randval.to_s)
      token = basetoken[0..10]
      self.update_column(:token,token)
    end
    token
  end

  def clear_token
    self.update_column(:token,nil)
  end

  def send_update_email
    UpdateMailer.with(owner: self).update_email.deliver
  end

  def self.send_update_emails
    self.human.each do |owner|
      owner.send_update_email
    end
  end

end
