module App
  class Registry

    @@registry = {}

    def self.find(key)
      @@registry[key]
    end

    def self.register(key, instance)
      @@registry[key] = instance
    end

    def self.bot_token_client
      @@registry[:bot_token_client]
    end
  end
end
