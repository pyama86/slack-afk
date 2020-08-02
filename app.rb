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

Dir[File.join(File.dirname(__FILE__), '../config/initializers/*.rb')].sort.each do |file|
  require file
end
