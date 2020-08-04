require 'slack-ruby-bot'
require './app'

server = SlackRubyBot::Server.new(
  token: ENV['SLACK_API_TOKEN'],
  hook_handlers: {
    message: [->(client, data) {
      entries = Redis.current.lrange("registered", 0, -1)
      mention = entries.find do |entry|
        data.text =~ /<@#{entry}>/
      end
      message = Redis.current.get(mention)
      client.say(text: "自動応答:#{message}", channel: data.channel,
                 thread_ts: data.thread_ts
                ) if mention && message
    }],
    ping: [->(client, data) {
    }],
    pong: [->(client, data) {
    }],
  }
)

Thread.new do
  server = TCPServer.new 1234
  loop do
    begin
      sock = server.accept
      line = sock.gets
      sock.write("HTTP/1.0 200 OK\n\nok")
      sock.close
    end
  end
end

server.run
