require 'sinatra'
require_relative 'app'
require_relative 'app/api'

run App::Api
