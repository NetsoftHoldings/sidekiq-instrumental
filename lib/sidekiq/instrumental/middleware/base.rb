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

        # Returns the human-friendly class name, if its a known wrapper we unwrap it.
        # Previously, this was done by the +display_name+ method of Sidekiq::Job,
        # but after this change (https://github.com/rails/rails/commit/0e64348ccaf513de731f403259ec5b49e7b3f028)
        # the method (https://github.com/mperham/sidekiq/blob/main/lib/sidekiq/api.rb#L342)
        # no longer works as expected as it compares a class against a string,
        # returning the wrapped job class not the class behind it as String.
        def unwrap_class_name(job)
          display_class = job.display_class

          if %w[ActionMailer::DeliveryJob ActionMailer::MailDeliveryJob]
               .include?(display_class.class.name)
            # The class name was not unwrapped correctly by the +display_class+ method
            job.args[0]['arguments'][0..1].join('#')
          else
            display_class
          end
        end
      end
    end
  end
end
