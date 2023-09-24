module App
  module Model
    class Comeback < Base
      def bot_run(uid, params)
        user_presence = App::Model::Store.get(uid)
        history = user_presence["mention_histotry"].map do |h|
<<-EOS
<@#{h['user']}>: <https://#{ENV['SLACK_DOMAIN']}/archives/#{h['channel']}/p#{h['event_ts'].gsub(/\./, '')}|Link>
内容: #{h['text']}
EOS
        end if user_presence["mention_histotry"]

        bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が戻ってきました。 I'll be back!!1", as_user: true)
        history ||= []
        if history.empty?
          "おかえりなさい!!1特にいない間にメンションは飛んでこなかったみたいです。\n\n\nいや、そういうわけじゃないで、気にしないでください・・・"
        else
          "おかえりなさい!!1\nいない間に飛んできたメンションです\n" + history.join("\n")
        end
      end
    end
  end
end
