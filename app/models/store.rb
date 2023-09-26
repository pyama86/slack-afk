module App
  module Model
    class Store
      def self.get(uid)
        redis_key = "#{uid}-store"
        raw_user_presence = RedisConnection.pool.get(redis_key)
        if raw_user_presence
          JSON.parse(raw_user_presence)
        else
          {
            'last_active_start_time' => Time.now.to_s
          }
        end
      end

      def self.set(uid, val, expire = 86_400 * 30)
        redis_key = "#{uid}-store"
        RedisConnection.pool.set(redis_key, val.to_json)
        RedisConnection.pool.expire(redis_key, expire)
      end
    end
  end
end
