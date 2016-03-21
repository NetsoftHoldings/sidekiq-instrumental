require 'sidekiq/api'

module Sidekiq
  module Instrumental
    module Middleware
      class Base
        attr_reader :config

        def initialize(config)
          @config = config
        end

        def call(worker_instance, msg, queue, redis_pool = nil)
          start_time = Time.now
          result = yield
          elapsed = (Time.now - start_time).to_f

          return result unless config.enabled?

          track(::Sidekiq::Stats.new, worker_instance, msg, queue, elapsed)

          result
        end

        protected

        def increment(*args)
          config.I.increment *args
        end

        def gauge(*args)
          config.I.gauge *args
        end
      end
    end
  end
end
