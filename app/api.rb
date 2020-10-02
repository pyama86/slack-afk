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

    post '/channel' do
      content_type 'text/plain; charset=utf8'
      cid = params["channel_id"]
      case params["command"]
      when "/enable_afk","/afk_enable"
        c = App::Model::Store.get(cid)
        c['enable'] = 1
        App::Model::Store.set(cid, c)
        "このチャンネルでの代理応答を有効にしました"
      when "/disable_afk","/afk_disable"
        c = App::Model::Store.get(cid)
        c['enable'] = 0
        App::Model::Store.set(cid, c)
        "このチャンネルでの代理応答を無効にしました"
      end
    rescue Slack::Web::Api::Errors::ChannelNotFound
      pp params
      "ボットがチャンネルで投稿できないみたいです。DMとかは無理です。"

    end

    post '/message' do
      content_type 'text/plain; charset=utf8'
      payload = JSON.parse(request.body.read)
      payload["challenge"]
    end

    post '/register' do
      content_type 'text/plain; charset=utf8'
      uid = params["user_id"]
      case params["command"]
      when "/start","/afk_start"
        App::Model::Start.new.run(uid, params)
      when /^\/afk\_*([0-9]*)/
        params["minute"] = $1
        App::Model::Afk.new.run(uid, params)
      when "/finish","/afk_finish"
        App::Model::Finish.new.run(uid, params)
      when "/lunch","/afk_lunch"
        App::Model::Lunch.new.run(uid, params)
      end
    rescue Slack::Web::Api::Errors::ChannelNotFound
      pp params
      "ボットがチャンネルで投稿できないみたいです。DMとかは無理です。"
    end

    post '/delete' do
      content_type 'text/plain; charset=utf8'
      uid = params["user_id"]
      App::Model::Comeback.new.run(uid, params)
    rescue Slack::Web::Api::Errors::ChannelNotFound
      pp params
      "ボットがチャンネルで投稿できないみたいです。DMとかは無理です。"
    end

    post '/stats' do
      content_type 'text/plain; charset=utf8'
      uid = params["user_id"]
      App::Model::Stats.new.run(uid, params)
    rescue Slack::Web::Api::Errors::ChannelNotFound
      pp params
      "ボットがチャンネルで投稿できないみたいです。DMとかは無理です。"
    end
  end
end
