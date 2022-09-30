require 'dotenv'
require 'config'
require './app/registry'
Dotenv.load

Dir[File.join(File.dirname(__FILE__), './config/initializers/*.rb')].sort.each do |file|
  require file
end

%w[
  mixins
  models
  libs
].each do |subdir|
  Dir[File.join(File.dirname(__FILE__), './app', subdir, '**/*.rb')].sort.each do |file|
    require file
  end
end
