require_relative 'base'
module App
  module Model
    class Afk < Base
      def add_list?
        true
      end

      def bot_run(uid, params)
        # ボットがDMとかで投稿できなくてもexpireはいれる
        unless params["minute"].empty?
          diff = params["minute"].to_i * 60
          Redis.current.expire(uid, diff.to_i)
        end

        unless params["text"].empty?
          Redis.current.set(uid, "#{params["user_name"]} は席を外しています。「#{params["text"]}」")
          bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が離席しました。「#{params["text"]}」",  as_user: true)
        else
          Redis.current.set(uid, "#{params["user_name"]} は席を外しています。反応が遅れるかもしれません。")
          bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が離席しました。代わりに不在をお伝えします",  as_user: true)
        end

        tips = [
          "\nちなみに通知も止めたいときは `/dnd 15min` とか `/dnd 1h` とかで通知も止められるし、 `/dnd off` で元に戻せるよ、知ってるとは思ったんだけど、念の為ね、知ってるとは思ったんだけどね",
          "\nちなみに、リマインドって知ってる？ `/remind @pyama この内容を15分後に@pyamaに通知するよ in 15min` とか `/remind @pyama この内容を1時間後に通知するよ in 1h` とかすると、15分後とか1時間後に @pyama さんに通知できるんだ、相手を気遣って時間ずらしてメンションしたいときとか使ってみてよ、いや、知ってるとは思ったんだけどね。 `/remind @pyama この内容を明日の10時に通知するよ in tomorrow at 10am` とかは流石に知らなかったでしょ？僕もさっき知ったしね、まあ知ってるとは思ったんだけどね。自分に設定したいときは `/remind` だけ押してエンター押してみてよ。"
        ]

        unless params["minute"].empty?
          "行ってらっしゃい!!1 #{(Time.now + diff).strftime("%H:%M")}に自動で解除します" + tips.sample
        else
          "行ってらっしゃい!!1" + tips.sample
        end
      end
    end
  end
end
