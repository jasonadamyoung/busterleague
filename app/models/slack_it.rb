# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class SlackIt

  attr_accessor :message, :attachments, :slack, :icon_emoji

  def initialize(options = {})

    username = options[:username] || "BusterBot"
    channel = options[:channel] || Settings.default_slack_channel
    @slack = Slack::Notifier.new(Settings.slack_webhook) do
      defaults channel: channel,
               username: username
    end
    @message = options[:message] || ''
    @attachments = options[:attachments]
    @icon_emoji = options[:icon_emoji]
    self
  end

  def post
    post_parameters = {}
    if(!self.attachments.blank?)
      if(self.attachments.is_a?(Array))
        post_parameters[:attachments] = self.attachments
      else
        post_parameters[:attachments] = [self.attachments]
      end
    end

    if(self.icon_emoji)
      post_parameters[:icon_emoji] = self.icon_emoji
    else
      post_parameters[:icon_emoji] = ':baseball:'
    end

    begin
      self.slack.ping(self.message, post_parameters)
    rescue StandardError => error
      Rollbar.log('error', e)
    end

  end

  def self.post(options = {})
    if(notification = self.new(options))
      notification.post
    end
  end

end
