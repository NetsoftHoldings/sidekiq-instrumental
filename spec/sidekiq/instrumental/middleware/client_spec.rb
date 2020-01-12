# frozen_string_literal: true

require 'spec_helper'

require 'active_support/core_ext/string/inflections'

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
end
