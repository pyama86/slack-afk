require 'redis'
ENV["REDIS_URL"] ||= 'redis://localhost:6379'

opt = {
  url: ENV["REDIS_URL"]
}
opt[:password] = ENV["REDIS_PASSWORD"] if ENV["REDIS_PASSWORD"]
opt[:db] = ENV["REDIS_DB"] if ENV["REDIS_DB"]
Redis.current = Redis.new(opt)
