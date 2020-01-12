# frozen_string_literal: true

require 'sidekiq/instrumental/version'
require 'sidekiq/instrumental/configuration'
require 'sidekiq/instrumental/middleware/base'
require 'sidekiq/instrumental/middleware/client'
require 'sidekiq/instrumental/middleware/server'
require 'sidekiq'

module Sidekiq
  module Instrumental # :nodoc:
    def self.config
      @config ||= Sidekiq::Instrumental::Configuration.new
    end

    def self.configure
      yield config if block_given?
      register
    end

    def self.register
      new_config = config.dup

      ::Sidekiq.configure_server do |config|
        config.server_middleware do |chain|
          chain.remove Sidekiq::Instrumental::Middleware::Server
          chain.add Sidekiq::Instrumental::Middleware::Server, new_config
        end
        config.client_middleware do |chain|
          chain.remove Sidekiq::Instrumental::Middleware::Client
          chain.add Sidekiq::Instrumental::Middleware::Client, new_config
        end
      end

      ::Sidekiq.configure_client do |config|
        config.client_middleware do |chain|
          chain.remove Sidekiq::Instrumental::Middleware::Client
          chain.add Sidekiq::Instrumental::Middleware::Client, new_config
        end
      end
    end
  end
end

Sidekiq::Instrumental.register
