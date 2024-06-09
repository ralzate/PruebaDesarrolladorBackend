require 'bundler/setup'
require 'logger'

ENV['RACK_ENV'] ||= 'development'
SINATRA_ROOT = Bundler.root.to_s
Bundler.require(:default, ENV['RACK_ENV'])

Mongoid.load!("#{SINATRA_ROOT}/mongoid.yml", ENV['RACK_ENV'])

require_relative 'games/utils/jwt_helper'
require_relative 'games/player'
require_relative 'games/hangman/hangman'
require_relative 'games/hangman/hangman_config'
require_relative 'games/hangman/word'
require_relative 'games/hangman/api'
require_relative 'games/panel/user'
require_relative 'games/panel/api'

module Games
  class Main < Sinatra::Application
    configure :development do
      Mongo::Logger.logger = Mongoid.logger = Logger.new($stdout)
    end

    if ENV['CORS_ORIGIN']
      use Rack::Cors do
        allow do
          # put real origins here
          origins ENV['CORS_ORIGIN'].split(',')
          # and configure real resources here
          resource '*', headers: :any, methods: [
            :get, :put, :delete, :patch, :post, :options
          ]
        end
      end
    end

    use Rack::Parser, parsers: {
      'application/json' => proc { |data| JSON.parse(data).with_indifferent_access },
      'application/xml'  => proc { |data| XML.parse(data).with_indifferent_access },
      /msgpack/          => proc { |data| Msgpack.parse(data).with_indifferent_access }
    }

    use Games::HangmanApi
    use Panel::Api
  end
end
