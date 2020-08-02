require 'sinatra/reloader' if development?
require 'sinatra/custom_logger'
require 'slack-ruby-bot'
require "redis"
require "thread"
require "json"
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

    post '/regist' do
      content_type 'text/plain; charset=utf8'
      uid = params["user_id"]
      reset(uid)
      Redis.current.lpush("registed", uid)
      case params["command"]
      when "/afk"
        unless params["text"].empty?
          Redis.current.set(uid, "#{params["user_name"]} からは席を外しています。「#{params["text"]}」")
        else
          Redis.current.set(uid, "#{params["user_name"]} は席を外しています。反応が遅れるかもしれません。")
        end
      when "/lunch"
        unless params["text"].empty?
          Redis.current.set(uid, "#{params["user_name"]} はランチに行っています。「#{params["text"]}」")
        else
          Redis.current.set(uid, "#{params["user_name"]} はランチに行っています。反応が遅れるかもしれません。")
        end
      end
      "行ってらっしゃい!!1"
    end

    post '/delete' do
      content_type 'text/plain; charset=utf8'
      uid = params["user_id"]
      reset(uid)
      "おかえりなさい!!1"
    end

    def reset(id)
      Redis.current.lrem("registed", 0, id)
      Redis.current.del(id)
    end
  end
end
