module App
  module Model
    class Comeback < Base

      def bot_run(uid, params)
        bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が戻ってきました。 I'll be back!!1", as_user: true)
        "おかえりなさい!!1"
      end
    end
  end
end
