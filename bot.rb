require 'slack-ruby-bot'
require "redis"
require './app'

require 'slack-ruby-bot'

server = SlackRubyBot::Server.new(
  token: ENV['SLACK_API_TOKEN'],
  hook_handlers: {
    message: [->(client, data) {
      entries = Redis.current.lrange("registed", 0, -1)
      mention = entries.find do |entry|
        data.text =~ /<@#{entry}>/
      end
      client.say(text: "自動応答:#{Redis.current.get(mention)}", channel: data.channel) if mention
    }]
  }
)

Thread.new do
  server = TCPServer.new 1234
  loop do
    begin
      sock = server.accept
      client.ping
      line = sock.gets
      sock.write("HTTP/1.0 200 OK\n\nok")
      sock.close
    end
  end
end

server.run
