require 'slack-ruby-bot'
['SLACK_API_TOKEN', 'SLACK_API_USER_TOKEN', 'SLACK_VERIFICATION_TOKEN'].each do |key|
  ENV[key] = ENV[key] &.chomp
end

SlackRubyBot::Client.logger.level = Logger::INFO
SlackRubyBot.configure do |config|
  config.allow_message_loops = false
end

App::Registry.register(:bot_token_client, Slack::Web::Client.new(token: ENV["SLACK_API_TOKEN"]))

SlackRubyBot::Client.logger.level = Logger::INFO
SlackRubyBot.configure do |config|
  config.allow_message_loops = false
end
