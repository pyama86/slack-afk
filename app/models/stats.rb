require 'terminal-table'
module App
  module Model
    class Stats < Base
      def run(uid, params)
        mentions = params["text"].scan(/@[\w-]+/)
        return "該当者がいないみたいです" if mentions.empty?
        mention = mentions[0].gsub(/@/, '')
        members = JSON.parse Redis.current.get("members")
        target = members.find do|m|
          m["name"] == mention
        end

        unless target
          groups = JSON.parse Redis.current.get("groups")
          target = groups.find do|m|
            m["name"] == mention
          end
          users = target["users"]
        else
          users = [target["id"]]
        end


        entries = Redis.current.lrange("registered", 0, -1)
        begin
          result = []
          users.each do |uid|
            us = App::Model::Store.get(uid)
            s = us["today_begin"] && DateTime.parse(us["today_begin"])
            l = us["last_lunch_date"] && DateTime.parse(us["last_lunch_date"])
            e = us["today_end"] && DateTime.parse(us["today_end"])

            start = s && s.today? ? s.strftime("%H:%M") : "本日の登録なし"
            lunch = l && l.today? ? l.strftime("%H:%M") : "本日の登録なし"
            _end = e && e.today? ? e.strftime("%H:%M") : "本日の登録なし"
            is_here = !entries.find {|entry| entry == uid }

            now = is_here ? "在席" : "離席"
            leave_message = is_here ? "" : Redis.current.get(uid)
            result << [us["name"], now, start, lunch, _end, leave_message]
          end

          table = Terminal::Table.new :title => "AFKサマリー", :headings => ['Slack Name', '在籍状況', '始業', 'ランチ', '退勤','離席理由'], :rows => result
          "#{table.to_s}\n※表がずれるのは、いつか・・・"
        rescue => e
          pp e
          "何かがだめでした"
        end
      end
    end
  end
end
