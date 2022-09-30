require 'redis'

module RedisConnection
  def self.pool
    return @pool if @pool

    ENV['REDIS_URL'] ||= 'redis://localhost:6379'

    opt = {
      url: ENV['REDIS_URL']
    }
    opt[:password] = ENV['REDIS_PASSWORD'] if ENV['REDIS_PASSWORD']
    opt[:db] = ENV['REDIS_DB'] if ENV['REDIS_DB']

    @pool = ConnectionPool::Wrapper.new(opt) do
      Redis.new(opt)
    end
  end

  def self.create_namespace(ns)
    Redis::Namespace.new(ns, redis: pool)
  end
end
