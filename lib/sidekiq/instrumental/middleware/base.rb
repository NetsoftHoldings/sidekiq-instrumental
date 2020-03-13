# frozen_string_literal: true

require 'sidekiq/api'

module Sidekiq
  module Instrumental
    module Middleware
      # Shared base code for measuring stats for server and client sidekiq
      class Base
        attr_reader :config

        def initialize(config)
          @config = config
        end

        def call(worker_instance, msg, queue, _redis_pool = nil)
          start_time = Time.now
          result = yield
          elapsed = (Time.now - start_time).to_f

          return result unless config.enabled?

          track(
            ::Sidekiq::Stats.new,
            worker_instance,
            ::Sidekiq::Job.new(msg),
            queue, elapsed
          )

          result
        end

        protected

        def increment(*args)
          config.I.increment(*args)
        end

        def gauge(*args)
          config.I.gauge(*args)
        end

        def build_class_key(klass_name)
          key = klass_name.underscore
                  .gsub(/[^\d\w\-_\.]/, '_')
                  .gsub(/\.{2,}/, '.')
          key.chomp!('.') while key[-1] == '.'
          key
        end
      end
    end
  end
end
