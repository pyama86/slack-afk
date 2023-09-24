module App
  module Model
    class Start < Base
      def add_list?
        true
      end

      def bot_run(uid, params)
        user_presence = App::Model::Store.get(uid)
        user_presence['today_begin'] = Time.now.to_s
        App::Model::Store.set(uid, user_presence)
        bot_token_client.chat_postMessage(channel: params['channel_id'], text: "#{params['user_name']}が始業しました。", as_user: true)
        response = (ENV['AFK_START_MESSAGE'] || 'おはようございます、今日も自分史上最高の日にしましょう!!1')
        if ENV['OPENAI_API_KEY']
          @openai_message ||= {}
          unless @openai_message[Date.today]
            r = openai_client.chat(
              parameters: {
                model: 'gpt-4',
                messages: [{ role: 'user', content: <<~EOS
                  これから送信するテキストをもっと面白くしてください。
                  送信するテキストは、始業時に従業員に伝達する文章です。
                  あなたが作成する文章は下記を要点とします。

                  1 .あなたに作成していただいたメッセージはそのままSlackで送信するので返信に件名は不要です。
                  2. 1日の始まりにテンションが上がる内容にしてください。
                  3. 今日は#{Date.today}です。日付にちなんだ面白い興味を引く文章にしてください。

                  テキスト: #{response}
                EOS
                }] # Required.
              }
            )
            @openai_message[Date.today] = r.dig('choices', 0, 'message', 'content')
          end
          response = @openai_message[Date.today]
        end
        response
      end
    end
  end
end
