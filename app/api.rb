require 'sinatra/reloader' if development?
require 'sinatra/custom_logger'
require "time"
require "json"
require "active_support/time"

module App
  class Api < Sinatra::Base
    include SlackApiCallerble
    helpers Sinatra::CustomLogger
    configure :development, :staging, :production do
      logger = Logger.new(STDERR)
      logger.level = Logger::DEBUG if development?
      set :logger, logger
      set :public_folder, 'assets/public'
    end

    # for livenessProbe
    get '/' do
      content_type 'text/plain; charset=utf8'
      'ok'
    end

    post '/message' do
      content_type 'text/plain; charset=utf8'
      payload = JSON.parse(request.body.read)
      payload["challenge"]
    end

    post '/register' do
      content_type 'text/plain; charset=utf8'
      uid = params["user_id"]
      reset(uid)
      Redis.current.lpush("registered", uid)
      case params["command"]
      when /^\/afk\_*([0-9]*)/
        minute = $1
        unless params["text"].empty?
          Redis.current.set(uid, "#{params["user_name"]} は席を外しています。「#{params["text"]}」")
        else
          Redis.current.set(uid, "#{params["user_name"]} は席を外しています。反応が遅れるかもしれません。")
        end

        bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が離席しました。代わりに不在をお伝えします",  as_user: true)
        unless minute.empty?
          diff = minute.to_i * 60
          Redis.current.expire(uid, diff.to_i)
          "行ってらっしゃい!!1 #{(Time.now + diff).strftime("%H:%M")}に自動で解除します"
        else
          "行ってらっしゃい!!1"
        end
      when "/finish"
        unless params["text"].empty?
          Redis.current.set(uid, "#{params["user_name"]} は退勤しました。「#{params["text"]}」")
        else
          Redis.current.set(uid, "#{params["user_name"]} は退勤しました。反応が遅れるかもしれません。")
        end
        tomorrow = Time.now.beginning_of_day + 3600 * 33
        Redis.current.expire(uid, (tomorrow - Time.now).to_i)
        bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}が退勤しました。お疲れさまでした！！１",  as_user: true)
        (ENV['AFK_FINISH_MESSAGE'] ||"お疲れさまでした!!1") + " 明日の#{tomorrow.strftime("%H:%M")}に自動で解除します"
      when "/lunch"
        unless params["text"].empty?
          Redis.current.set(uid, "#{params["user_name"]} はランチに行っています。「#{params["text"]}」")
        else
          Redis.current.set(uid, "#{params["user_name"]} はランチに行っています。反応が遅れるかもしれません。")
        end
        Redis.current.expire(uid, 3600)
        bot_token_client.chat_postMessage(channel: params["channel_id"], text: "#{params["user_name"]}がランチに行きました。何食べるんでしょうね？", as_user: true)
        "行ってらっしゃい!!1 #{(Time.now + 3600).strftime("%H:%M")}に自動で解除します"
      end
    end

    post '/delete' do
      content_type 'text/plain; charset=utf8'
      uid = params["user_id"]
      reset(uid)
      "おかえりなさい!!1"
    end

    def reset(id)
      Redis.current.lrem("registered", 0, id)
      Redis.current.del(id)
    end
  end
end
