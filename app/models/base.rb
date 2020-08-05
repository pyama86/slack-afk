module App
  module Model
    class Base
      include SlackApiCallerble
      def reset(uid)
        Redis.current.lrem("registered", 0, uid)
        Redis.current.del(uid)
      end

      def add_list?
        false
      end

      def bot_run(uid, params)
        raise "bot run isn't defined"
      end

      def run(uid, params)
        reset(uid)
        Redis.current.lpush("registered", uid) if add_list?
        bot_run(uid, params)
      end
    end
  end
end
