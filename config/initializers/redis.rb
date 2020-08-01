ENV["REDIS_URL"] ||= 'redis://localhost:6379'
if App.env.test?
  ENV["REDIS_URL"] += '/10'
end

url = ENV["REDIS_URL"]

Redis.current = Redis.new(url: url)
