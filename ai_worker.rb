require_relative 'app'
require 'openai'
return unless ENV['OPENAI_API_KEY']

openai = ::OpenAI::Client.new(
  access_token: ENV['OPENAI_API_KEY']
)
if ENV['AFK_START_MESSAGE'] && RedisConnection.pool.get("start_#{Date.today}").nil?
  response = openai.chat(
    parameters: {
      model: 'gpt-4',
      messages: [{ role: 'user', content: <<~EOS
        これから入力するテキストは従業員の始業時に通知するメッセージです。
        モチベーションが上がるような内容に修正してください。
        作成してもらう文章は下記を要点とします。

        1. 今日は#{Date.today}です。従業員に対して、日付にちなんだ面白い興味を引く文章にしてください。
        2. あなたに作成していただいたメッセージはSlackで送信するので返信に件名は不要です。

        テキスト:#{ENV['AFK_START_MESSAGE']}
      EOS
      }] # Required.
    }
  )

  r = response.dig('choices', 0, 'message', 'content')
  puts "start_message: #{r}"
  RedisConnection.pool.set("start_#{Date.today}", r)
  RedisConnection.pool.expire("start_#{Date.today}", 86_400)
end

if ENV['AFK_FINISH_MESSAGE'] && RedisConnection.pool.get("finish_#{Date.today}").nil?
  response = openai.chat(
    parameters: {
      model: 'gpt-4',
      messages: [{ role: 'user', content: <<~EOS
        これから入力するテキストは従業員の終業時に通知するメッセージです。
        労を労い、自己肯定感が上がるような内容に修正してください。
        作成してもらう文章は下記を要点とします。

        1. 今日は#{Date.today}です。従業員に対して、日付にちなんだ面白い興味を引く文章にしてください。
        2. あなたに作成していただいたメッセージはSlackで送信するので返信に件名は不要です。

        テキスト:#{ENV['AFK_FINISH_MESSAGE']}
      EOS
      }] # Required.
    }
  )

  r = response.dig('choices', 0, 'message', 'content')
  puts "finish_message: #{r}"
  RedisConnection.pool.set("finish_#{Date.today}", r)
  RedisConnection.pool.expire("finish_#{Date.today}", 86_400)

end
