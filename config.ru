require 'sinatra'
require './app'
require_relative 'app/registry'
require_relative 'app/api'

run App::Api
