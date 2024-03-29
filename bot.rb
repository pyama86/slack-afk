require 'slack-ruby-bot'
require './app'
server = SlackRubyBot::Server.new(
  token: ENV['SLACK_API_TOKEN'],
  hook_handlers: {
    message: [lambda { |client, data|
      return if data.subtype == 'channel_join'
      return if data.subtype == 'bot_message'
      return if data.text =~ /\+\+|is up to [0-9]+ points!/

      entries = RedisConnection.pool.lrange('registered', 0, -1)
      uids = entries.select do |entry|
        data.text =~ /<@#{entry}>/
      end

      cid = data.channel
      c = App::Model::Store.get(cid)

      uids.each do |uid|
        message = RedisConnection.pool.get(uid)
        next unless message && c.fetch('enable', 1) == 1

        user_presence = App::Model::Store.get(uid)
        user_presence['mention_histotry'] ||= []
        user_presence['mention_histotry'] = [] if user_presence['mention_histotry'].is_a?(Hash)
        user_presence['mention_histotry'] << {
          channel: data.channel,
          user: data.user,
          text: data.text && data.text.gsub(/<@#{uid}>/, ''),
          event_ts: data.event_ts
        }
        App::Model::Store.set(uid, user_presence)

        client.say(text: "自動応答: #{message}", channel: data.channel,
                   thread_ts: data.thread_ts)
      end
    }],
    ping: [lambda { |client, data|
    }],
    pong: [lambda { |client, data|
    }]
  }
)

Thread.new do
  server = TCPServer.new('0.0.0.0', 1234)
  loop do
    sock = server.accept
    line = sock.gets
    sock.write("HTTP/1.0 200 OK\n\nok")
    sock.close
  end
end

server.run
