module App
  module Model
    class Finish < Base
      def add_list?
        true
      end

      def bot_run(uid, params)
        if params['text'].empty?
          RedisConnection.pool.set(uid, "#{params['user_name']} は退勤しました。反応が遅れるかもしれません。")
        else
          RedisConnection.pool.set(uid, "#{params['user_name']} は退勤しました。「#{params['text']}」")
        end
        tomorrow = Time.now.beginning_of_day + 3600 * 33
        RedisConnection.pool.expire(uid, (tomorrow - Time.now).to_i)

        user_presence = App::Model::Store.get(uid)
        begin_time = user_presence['today_begin']
        user_presence['today_end'] = Time.now.to_s
        App::Model::Store.set(uid, user_presence)

        bot_token_client.chat_postMessage(channel: params['channel_id'], text: "#{params['user_name']}が退勤しました。お疲れさまでした！！１", as_user: true)
        message = (ENV['AFK_FINISH_MESSAGE'] || 'お疲れさまでした!!1')

        if ENV['OPENAI_API_KEY']
          @openai_message ||= {}
          unless @openai_message[Date.today]
            r = openai_client.chat(
              parameters: {
                model: 'gpt-4',
                messages: [{ role: 'user', content: <<~EOS
                  これから送信するテキストをもっと面白くしてください。
                  送信するテキストは、就業時に従業員に伝達する文章です。
                  あなたが作成する文章は下記を要点とします。

                  1 .あなたに作成していただいたメッセージはそのままSlackで送信するので返信に件名は不要です。
                  2. 1日の終わりに自己肯定感が上がる内容にしてください。
                  3. 今日は#{Date.today}です。日付にちなんだ面白い興味を引く文章にしてください。

                  テキスト: #{message}
                EOS
                }] # Required.
              }
            )
            @openai_message[Date.today] = r.dig('choices', 0, 'message', 'content')
          end
          message = @openai_message[Date.today]
        end

        message + (begin_time ? "始業時刻:#{Time.parse(begin_time).strftime('%H:%M')}\n" : '') +
          " 明日の#{tomorrow.strftime('%H:%M')}に自動で解除します"
      end
    end
  end
end
