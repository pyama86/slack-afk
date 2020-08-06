require 'slack-ruby-client'
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

channels = []
next_cursor = nil
loop do
  slack_channels = slack.conversations_list({limit: 1000, cursor: next_cursor})
  channels << slack_channels['channels']
  next_cursor = slack_channels['response_metadata']['next_cursor']
  break if next_cursor.empty?
end
channels.flatten!

channels.each do |c|
  next_cursor = nil
  loop do
    c["members"] ||= []
    break if c["num_members"] == 0 || c["is_archived"]
    channel_members = slack.conversations_members({channel: c["id"], limit: 1000, cursor: next_cursor})
    c["members"] << channel_members['members']
    next_cursor = channel_members['response_metadata']['next_cursor']
    break if next_cursor.empty?
  end
end

user = members.find {|m|m["name"] == ENV['SLACK_USER']}
exclude_channels = ENV['SLACK_EXCLUDE_CHANNELS'] ? ENV['SLACK_EXCLUDE_CHANNELS'].split(/,/) : []
channels.each do |c|
  next if c["is_archived"]
  next if c["members"].empty? || c["members"].flatten.find {|m| m == user["id"]}
  next if exclude_channels.include?(c["name"])
  begin
    slack.conversations_invite({channel: c["id"], users: user["id"]})
  rescue Slack::Web::Api::Errors::AlreadyInChannel
    next
  rescue Slack::Web::Api::Errors::NotInChannel
    slack.conversations_join({channel: c["id"]})
    begin
      slack.conversations_invite({channel: c["id"], users: user["id"]})
    rescue Slack::Web::Api::Errors::AlreadyInChannel
      next
    ensure
      slack.conversations_leave({channel: c["id"]})
    end
  rescue => e
    pp c
    pp e
  end
end

