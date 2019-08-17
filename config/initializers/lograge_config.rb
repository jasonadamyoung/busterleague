Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    unwanted_keys = %w[format action controller utf8]
    params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }
    {time: event.time.to_s(:db), owner_id: event.payload[:owner_id], remote_ip: event.payload[:remote_ip], request_ip: event.payload[:request_ip], params: params}
  end

  config.lograge.ignore_actions = ['OkComputer::OkComputerController#show','OkComputer::OkComputerController#index']
  config.lograge.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
end
