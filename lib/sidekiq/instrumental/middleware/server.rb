# frozen_string_literal: true

module Sidekiq
  module Instrumental
    module Middleware
      # Server side sidekiq middleware
      class Server < Base
        protected

        def track(stats, worker_instance, msg, queue, elapsed)
          submit_general_stats(stats)

          return unless config.allowed_to_submit queue, worker_instance

          base_key = "sidekiq_#{queue}_"

          increment(base_key + 'processed')
          gauge(base_key + 'time', elapsed)
          gauge(base_key + 'enqueued', stats.queues[queue].to_i)
          gauge(base_key + 'latency', Sidekiq::Queue.new(queue.to_s).latency)

          display_class = unwrap_class_name(msg)
          base_key += build_class_key(display_class) + '_'

          increment(base_key + 'processed')
          gauge(base_key + 'time', elapsed)

          push_metrics
        end

        def submit_general_stats(stats)
          increment('sidekiq_processed')
          {
            enqueued: nil,
            failed: nil,
            scheduled_size: 'scheduled'
          }.each do |method, name|
            gauge("sidekiq_#{(name || method)}", stats.send(method).to_i)
          end
        end
      end
    end
  end
end
