require 'sinatra'
require_relative 'app'
require_relative 'app/api'
use Rack::RewindableInput::Middleware
run App::Api
