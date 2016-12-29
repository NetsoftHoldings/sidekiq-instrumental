module Sidekiq
  module Instrumental
    module Middleware
      class Server < Base
        protected

        def track(stats, worker_instance, msg, queue, elapsed)
          submit_general_stats(stats)

          return unless config.allowed_to_submit queue, worker_instance

          base_key = "sidekiq.#{queue.to_s}."

          increment(base_key + 'processed')
          gauge(base_key + 'time', elapsed)
          gauge(base_key + 'enqueued', stats.queues[queue].to_i)
          gauge(base_key + 'latency', Sidekiq::Queue.new(queue.to_s).latency)
          base_key += msg['class'].underscore.gsub('/', '_') + '.'

          increment(base_key + 'processed')
          increment(base_key + 'time', elapsed)
        end

        def submit_general_stats(stats)
          increment("sidekiq.processed")
          {
              enqueued: nil,
              failed: nil,
              scheduled_size: 'scheduled'
          }.each do |method, name|
            gauge("sidekiq.#{(name || method).to_s}", stats.send(method).to_i)
          end
        end
      end
    end
  end
end
