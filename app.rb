require "dotenv"
require 'config'
Dotenv.load

[
  'mixins',
].each { |subdir|
  Dir[File.join(File.dirname(__FILE__), 'app', subdir, '**/*.rb')].sort.each do |file|
    require file
  end
}

Config.load_and_set_settings(Config.setting_files("config", ENV['APP_ENV']))
module App
  def logger
    App::Bot.instance.logger
  end

  def env
    @env ||= Class.new {
      class << self
        def production?
          ENV["APP_ENV"] == 'production'
        end

        def development?
          ENV["APP_ENV"] == 'development'
        end

        def test?
          ENV["APP_ENV"] == 'test'
        end
      end
    }
  end

  module_function :logger
  module_function :env
end
