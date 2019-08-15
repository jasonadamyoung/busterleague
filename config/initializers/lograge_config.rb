Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    unwanted_keys = %w[format action controller utf8]
    params = event.payload[:params].reject { |key,_| unwanted_keys.include? key }
    {time: event.time.to_s(:db), owner_id: event.payload[:owner_id], ip: event.payload[:ip], params: params}
  end
  config.lograge.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
end
