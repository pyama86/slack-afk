require 'openai'

App::Registry.register(:openai_client, ::OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])) if ENV['OPENAI_API_KEY']
