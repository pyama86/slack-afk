require 'slack-ruby-bot'
require './app'

require 'slack-ruby-bot'

server = SlackRubyBot::Server.new(
  token: ENV['SLACK_API_TOKEN'],
  hook_handlers: {
    message: [->(client, data) {
      if data.text =~  /<@U03Q3PPSX>/
      client.say(text: "@pyamaはキャンプに行っています", channel: data.channel)
      end
    }]
  }
)

server.run
