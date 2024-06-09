require 'bundler/setup'
Bundler.require(:default)

require File.dirname(__FILE__) + "/main.rb"

map '/' do
    run Games::Main
end

