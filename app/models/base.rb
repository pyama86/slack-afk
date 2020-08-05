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
        if add_list?
          Redis.current.lpush("registered", uid)
          user_presence = App::Model::Store.get(uid)
          user_presence["mention_histotry"] = []
          App::Model::Store.set(uid, user_presence)
        end

        bot_run(uid, params)
      end
    end
  end
end
