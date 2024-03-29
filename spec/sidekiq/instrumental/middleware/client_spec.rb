# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Instrumental::Middleware::Client do
  let(:config) { Sidekiq::Instrumental::Configuration.new }
  let(:middleware) { described_class.new(config) }
  let(:sidekiq_stats) { double('Sidekiq::Stats') }
  let(:worker) { {} }
  let(:msg) { { 'class' => 'MyClassName' } }
  let(:queue) { 'default' }

  before do
    allow(config).to receive(:enabled?).and_return(true)
    allow(middleware).to receive(:increment)
    allow(::Sidekiq::Stats).to receive(:new).and_return(sidekiq_stats)
  end

  subject { middleware.call(worker, msg, queue) {} }

  it 'increments the queued metric' do
    expect(middleware).to receive(:increment).with('sidekiq.queued')

    subject
  end

  it 'checks if the worker class is allowed to submit detailed metrics' do
    expect(config).to receive(:allowed_to_submit).with(queue, worker)

    subject
  end

  it 'increments the queued metric for the queue' do
    expect(middleware).to receive(:increment).with("sidekiq.#{queue}.queued")

    subject
  end

  describe 'metric naming' do
    context 'when the class name contains unsupported characters' do
      let(:msg) { { 'class' => 'MyMailer#message/fun' } }

      it 'changes them to _' do
        expect(middleware).to receive(:increment)
                                .with("sidekiq.#{queue}.my_mailer_message_fun.queued")

        subject
      end
    end

    context 'when the class name causes more then one . in a row' do
      let(:msg) { { 'class' => 'MyMailer..message' } }

      it 'combines them to one' do
        expect(middleware).to receive(:increment)
                                .with("sidekiq.#{queue}.my_mailer.message.queued")

        subject
      end
    end

    context 'trims a trailing .' do
      let(:msg) { { 'class' => 'MyMailer#message.' } }

      it 'combines them to one' do
        expect(middleware).to receive(:increment)
                                .with("sidekiq.#{queue}.my_mailer_message.queued")

        subject
      end
    end

    context 'when the class is not passed as a string' do
      let(:msg) { { 'class' => stub_const('MyClassName', Class.new) } }

      it 'increments the queued metric for the queue' do
        expect(middleware).to receive(:increment).with("sidekiq.#{queue}.queued")

        subject
      end
    end
  end

  it 'calls display_class to get the class name' do
    expect_any_instance_of(::Sidekiq::Job)
      .to receive(:display_class).and_call_original

    subject
  end

  it 'increments the queued metric for the worker class name' do
    expect(middleware).to receive(:increment)
                            .with("sidekiq.#{queue}.my_class_name.queued")

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
                  .with("sidekiq.#{queue}.user_mailer_confirm_account.queued")

          subject
        end
      end

      context 'when passed as a Class' do
        let(:passed_class) { wrapped_class }

        it 'unwraps the class name and increments the metric' do
          expect(middleware)
            .to receive(:increment)
                  .with("sidekiq.#{queue}.user_mailer_confirm_account.queued")

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
                  .with("sidekiq.#{queue}.jobs_job.queued")

          subject
        end
      end

      context 'when passed as a Class' do
        let(:passed_class) { wrapped_class }

        it 'unwraps the class name and increments the metric' do
          expect(middleware)
            .to receive(:increment)
                  .with("sidekiq.#{queue}.jobs_job.queued")

          subject
        end
      end
    end
  end
end
