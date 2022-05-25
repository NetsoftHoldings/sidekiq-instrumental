# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Instrumental::Middleware::Server do
  let(:config) { Sidekiq::Instrumental::Configuration.new }
  let(:middleware) { described_class.new(config) }
  let(:sidekiq_stats) do
    instance_double('Sidekiq::Stats',
                    enqueued: 1,
                    failed: 2,
                    scheduled_size: 3,
                    queues: { queue => 4 })
  end
  let(:sidekiq_queue) { instance_double('Sidekiq::Queue', latency: 5) }
  let(:worker) { {} }
  let(:msg) { { 'class' => 'MyClassName' } }
  let(:queue) { 'default' }

  before do
    allow(config).to receive(:enabled?).and_return(true)
    allow(middleware).to receive(:increment)
    allow(middleware).to receive(:gauge)
    allow(::Sidekiq::Stats).to receive(:new).and_return(sidekiq_stats)
    allow(::Sidekiq::Queue).to receive(:new).and_return(sidekiq_queue)
  end

  subject do
    Timecop.freeze do
      middleware.call(worker, msg, queue) do
        Timecop.travel(0.5)
      end
    end
  end

  it 'submits general stats' do
    expect(middleware).to receive(:gauge)
                            .with('sidekiq.enqueued', 1)
    expect(middleware).to receive(:gauge)
                            .with('sidekiq.failed', 2)
    expect(middleware).to receive(:gauge)
                            .with('sidekiq.scheduled', 3)

    subject
  end

  it 'increments the processed metric' do
    expect(middleware).to receive(:increment)
                            .with('sidekiq.processed')

    subject
  end

  it 'increments the processed metric for the queue' do
    expect(middleware).to receive(:increment)
                            .with("sidekiq.#{queue}.processed")

    subject
  end

  it 'gauge the elapsed time metric for the queue' do
    expect(middleware).to receive(:gauge)
                            .with(
                              "sidekiq.#{queue}.time",
                              be_within(0.001).of(0.5)
                            )

    subject
  end

  it 'gauge the enqueued metric for the queue' do
    expect(middleware).to receive(:gauge)
                            .with("sidekiq.#{queue}.enqueued", 4)

    subject
  end

  it 'gauge the latency metric for the queue' do
    expect(middleware).to receive(:gauge)
                            .with("sidekiq.#{queue}.latency", 5)

    subject
  end

  it 'increments processed metric for the class' do
    expect(middleware).to receive(:increment)
                            .with("sidekiq.#{queue}.my_class_name.processed")

    subject
  end

  describe 'metric naming' do
    context 'when the class name contains unsupported characters' do
      let(:msg) { { 'class' => 'MyMailer#message/fun' } }

      it 'changes them to _' do
        expect(middleware).to receive(:increment)
                                .with("sidekiq.#{queue}.my_mailer_message_fun.processed")

        subject
      end
    end

    context 'when the class name causes more then one . in a row' do
      let(:msg) { { 'class' => 'MyMailer..message' } }

      it 'combines them to one' do
        expect(middleware).to receive(:increment)
                                .with("sidekiq.#{queue}.my_mailer.message.processed")

        subject
      end
    end

    context 'trims a trailing .' do
      let(:msg) { { 'class' => 'MyMailer#message.' } }

      it 'combines them to one' do
        expect(middleware).to receive(:increment)
                                .with("sidekiq.#{queue}.my_mailer_message.processed")

        subject
      end
    end

    context 'when the class is not passed as a string' do
      let(:msg) { { 'class' => stub_const('MyClassName', Class.new) } }

      it 'increments the queued metric for the queue' do
        expect(middleware).to receive(:increment).with("sidekiq.#{queue}.processed")

        subject
      end
    end
  end

  it 'gauge elapsed time metric for the class' do
    expect(middleware).to receive(:gauge)
                            .with(
                              "sidekiq.#{queue}.my_class_name.time",
                              be_within(0.001).of(0.5)
                            )

    subject
  end

  describe 'Unwrap sidekiq job class name' do
    let(:msg) do
      {
        'class' => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
        'wrapped' => passed_class,
        'args' => args
      }
    end
    let(:args) { [] }

    context "when sidekiq's wrapped class is a mail delivery job" do
      let(:wrapped_class) { stub_const('ActionMailer::DeliveryJob', Class.new) }
      let(:args) { [{ 'arguments' => %w[UserMailer confirm_account deliver_now User] }] }

      context 'when passed as a String' do
        let(:passed_class) { wrapped_class.to_s }

        it 'unwraps the class name and increments the metric' do
          expect(middleware)
            .to receive(:increment)
                  .with("sidekiq.#{queue}.user_mailer_confirm_account.processed")

          subject
        end
      end

      context 'when passed as a Class' do
        let(:passed_class) { wrapped_class }

        it 'unwraps the class name and increments the metric' do
          expect(middleware)
            .to receive(:increment)
                  .with("sidekiq.#{queue}.user_mailer_confirm_account.processed")

          subject
        end
      end
    end

    context "when sidekiq's wrapped class is not a mail delivery job" do
      let(:wrapped_class) { stub_const('Jobs::Job', Class.new) }

      context 'when passed as a String' do
        let(:passed_class) { wrapped_class.to_s }

        it 'unwraps the class name and increments the metric' do
          expect(middleware)
            .to receive(:increment)
                  .with("sidekiq.#{queue}.jobs_job.processed")

          subject
        end
      end

      context 'when passed as a Class' do
        let(:passed_class) { wrapped_class }

        it 'unwraps the class name and increments the metric' do
          expect(middleware)
            .to receive(:increment)
                  .with("sidekiq.#{queue}.jobs_job.processed")

          subject
        end
      end
    end
  end
end
