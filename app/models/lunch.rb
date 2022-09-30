module App
  module Model
    class Lunch < Base
      def add_list?
        true
      end

      def bot_run(uid, params)
        unless params["text"].empty?
          RedisConnection.pool.set(uid, "#{params["user_name"]} はランチに行っています。「#{params["text"]}」")
        else
          RedisConnection.pool.set(uid, "#{params["user_name"]} はランチに行っています。反応が遅れるかもしれません。")
        end
        RedisConnection.pool.expire(uid, 3600)
        bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}がランチに行きました。何食べるんでしょうね？", as_user: true)
        return_message "行ってらっしゃい!!1 #{(Time.now + 3600).strftime("%H:%M")}に自動で解除します"

        user_presence = App::Model::Store.get(uid)
        user_presence["last_lunch_date"] = Time.now.to_s
        App::Model::Store.set(uid, user_presence)
      end
    end
  end
end
