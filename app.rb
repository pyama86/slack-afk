require "dotenv"
require 'config'
Dotenv.load

Dir[File.join(File.dirname(__FILE__), './config/initializers/*.rb')].sort.each do |file|
  require file
end
