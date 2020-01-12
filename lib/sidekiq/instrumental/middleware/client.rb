# frozen_string_literal: true

module Sidekiq
  module Instrumental
    module Middleware
      # Client side sidekiq middleware
      class Client < Base
        def track(_stats, worker_instance, msg, queue, _elapsed)
          increment('sidekiq.queued')

          return unless config.allowed_to_submit queue, worker_instance

          base_key = "sidekiq.#{queue}."
          increment(base_key + 'queued')

          base_key += msg.display_class.underscore.gsub('/', '_') + '.'

          increment(base_key + 'queued')
        end
      end
    end
  end
end
