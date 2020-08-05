require './app'
require 'json'
require 'time'

slack = Slack::Web::Client.new(token: ENV["SLACK_API_TOKEN"])

members = []
next_cursor = nil

loop do
  slack_users = slack.users_list({limit: 1000, cursor: next_cursor})
  members << slack_users['members']
  next_cursor = slack_users['response_metadata']['next_cursor']
  break if next_cursor.empty?
end
members.flatten!

members.each do |m|
  uid = m["id"]
  redis_key = "#{uid}-presence"
  next if m["is_bot"] || m["deleted"]
  begin
    presence = slack.users_getPresence({user: m["id"]})["presence"]
  rescue Slack::Web::Api::Errors::TooManyRequestsError
    sleep 5
    retry
  end
  user_presence = App::Model::Store.get(uid)
  if user_presence['status'] != presence
    # awayになったときにactiveだった時間を記録する
    if presence == 'away'
        user_presence['history'] ||= []
        user_presence['history'] << {
          start: user_presence['last_active_start_time'],
          end: Time.now.to_s
        }
    else
      user_presence['last_active_start_time'] = Time.now.to_s
    end
  end
  user_presence['status'] = presence
  user_presence['name'] = m['name']

  # 1ヶ月前のデータは削除する
  user_presence['history'].reject! do |h|
    next unless h['start']
    Time.parse(h['start']) < Time.now - 30 + 86400
  end if user_presence['history'] && !user_presence['history'].empty?
  App::Model::Store.set(uid, user_presence, 86400*10)
end
