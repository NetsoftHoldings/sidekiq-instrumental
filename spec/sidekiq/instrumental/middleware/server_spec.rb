# frozen_string_literal: true

require 'spec_helper'

require 'active_support/core_ext/string/inflections'

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

  it 'gauge elapsed time metric for the class' do
    expect(middleware).to receive(:gauge)
                            .with(
                              "sidekiq.#{queue}.my_class_name.time",
                              be_within(0.001).of(0.5)
                            )

    subject
  end
end