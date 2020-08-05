module App
  module Model
    class Start < Base
      def add_list?
        true
      end

      def bot_run(uid, params)
          Redis.current.set("#{uid}-begin", Time.now.to_s)
          bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が始業しました。",  as_user: true)
          (ENV['AFK_START_MESSAGE'] ||"おはようございます、今日も自分史上最高の日にしましょう!!1")
      end
    end
  end
end
