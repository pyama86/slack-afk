module App
  module Model
    class Store
      def self.get(uid)
        redis_key = "#{uid}-store"
        raw_user_presence = Redis.current.get(redis_key)
        unless raw_user_presence
          {
            'last_active_start_time' => Time.now.to_s
          }
        else
          JSON.parse(raw_user_presence)
        end
      end

      def self.set(uid, val, expire=0)
        redis_key = "#{uid}-store"
        Redis.current.set(redis_key, val.to_json)
        Redis.current.expire(redis_key, expire) if expire != 0
      end
    end
  end
end
