module Sidekiq
  module Instrumental
    module Middleware
      class Client < Base

        def track(stats, worker_instance, msg, queue, elapsed)

          increment('sidekiq.queued')

          #return unless config.allowed_to_submit queue, worker_instance

          base_key = "sidekiq.#{queue.to_s}."
          increment(base_key + 'queued')

          base_key += msg['class'].underscore.gsub('/', '_') + '.'

          increment(base_key + 'queued')
        end
      end
    end
  end
end