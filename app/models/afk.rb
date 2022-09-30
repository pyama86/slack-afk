require_relative 'base'
module App
  module Model
    class Afk < Base
      def add_list?
        true
      end

      def bot_run(uid, params)
        unless params["text"].empty?
          RedisConnection.pool.set(uid, "#{params["user_name"]} は席を外しています。「#{params["text"]}」")
          bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が離席しました。「#{params["text"]}」",  as_user: true)
        else
          RedisConnection.pool.set(uid, "#{params["user_name"]} は席を外しています。反応が遅れるかもしれません。")
          bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が離席しました。代わりに不在をお伝えします",  as_user: true)
        end

        # ボットがDMとかで投稿できなくてもexpireはいれる
        unless params["minute"].empty?
          diff = params["minute"].to_i * 60
          RedisConnection.pool.expire(uid, diff.to_i)
        end

        unless params["minute"].empty?
          return_message "行ってらっしゃい!!1 #{(Time.now + diff).strftime("%H:%M")}に自動で解除します"
        else
          return_message "行ってらっしゃい!!1"
        end
      end
    end
  end
end
