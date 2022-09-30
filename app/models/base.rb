module App
  module Model
    class Base
      include SlackApiCallerble
      def reset(uid)
        RedisConnection.pool.lrem("registered", 0, uid)
        RedisConnection.pool.del(uid)
      end

      def add_list?
        false
      end


      def return_message(message)
        message + tips
      end

      def tips
        [
          "\nちなみに通知も止めたいときは `/dnd 15min` とか `/dnd 1h` とかで通知も止められるし、 `/dnd off` で元に戻せるよ、知ってるとは思ったんだけど、念の為ね、知ってるとは思ったんだけどね",
          "\nちなみに、リマインドって知ってる？ `/remind @pyama この内容を15分後に@pyamaに通知するよ in 15min` とか `/remind @pyama この内容を1時間後に通知するよ in 1h` とかすると、15分後とか1時間後に @pyama さんに通知できるんだ、相手を気遣って時間ずらしてメンションしたいときとか使ってみてよ、いや、知ってるとは思ったんだけどね。 `/remind @pyama この内容を明日の10時に通知するよ in tomorrow at 10am` とかは流石に知らなかったでしょ？僕もさっき知ったしね、まあ知ってるとは思ったんだけどね。自分に設定したいときは `/remind` だけ押してエンター押してみてよ。"
        ].sample
      end

      def bot_run(uid, params)
        raise "bot run isn't defined"
      end

      def run(uid, params)
        reset(uid)
        if add_list?
          RedisConnection.pool.lpush("registered", uid)
          user_presence = App::Model::Store.get(uid)
          user_presence["mention_histotry"] = []
          App::Model::Store.set(uid, user_presence)
        end

        bot_run(uid, params)
      end
    end
  end
end
