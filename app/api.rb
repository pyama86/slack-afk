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

      Dir[File.join(File.dirname(__FILE__), '../config/initializers/*.rb')].sort.each do |file|
        require file
      end
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
      Redis.current.lpush("users", params["user_name"])
      "See you later!!1"
    end

    post '/delete' do
      content_type 'text/plain; charset=utf8'
      Redis.current.lrem("users", 1, params["user_name"])
      "Let's work together!!1"
    end
  end
end
