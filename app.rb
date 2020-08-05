require "dotenv"
require 'config'
require './app/registry'
Dotenv.load

Dir[File.join(File.dirname(__FILE__), './config/initializers/*.rb')].sort.each do |file|
  require file
end

[
  'mixins',
  'models',
].each { |subdir|
  Dir[File.join(File.dirname(__FILE__), './app', subdir, '**/*.rb')].sort.each do |file|
    require file
  end
}
