require 'slack-ruby-bot'
SlackRubyBot::Client.logger.level = Logger::INFO
SlackRubyBot.configure do |config|
  config.allow_message_loops = false
end

App::Registry.register(:bot_token_client, Slack::Web::Client.new(token: ENV["SLACK_API_TOKEN"]))
