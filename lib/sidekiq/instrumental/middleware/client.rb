# frozen_string_literal: true

module Sidekiq
  module Instrumental
    module Middleware
      # Client side sidekiq middleware
      class Client < Base
        def track(_stats, worker_instance, msg, queue, _elapsed)
          increment('sidekiq_queued')

          return unless config.allowed_to_submit queue, worker_instance

          base_key = "sidekiq_#{queue}_"
          increment(base_key + 'queued')

          display_class = unwrap_class_name(msg)
          base_key += build_class_key(display_class) + '_'

          increment(base_key + 'queued')
          push_metrics
        end
      end
    end
  end
end
