# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Instrumental do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '::config' do
    describe '::config' do
      it 'should return a Configuration object' do
        expect(described_class.config)
          .to be_an_instance_of(described_class::Configuration)
      end
    end
  end

  describe '::configure' do
    before do
      allow(described_class).to receive(:register)
    end
    it 'should yield to the passed block' do
      expect { |b| described_class.configure(&b) }.to yield_control
    end

    it 'should yield the configuration object' do
      expect { |b| described_class.configure(&b) }
        .to yield_with_args(described_class.config)
    end
  end

  describe '::register' do
    context 'when sidekiq run as a server' do
      before do
        allow(Sidekiq).to receive(:server?).and_return(true)
      end

      it 'should register server middleware' do
        server_chain = double('Sidekick::MiddlewareChain')
        config = double('Chain')
        allow(config).to receive(:server_middleware).and_yield(server_chain)
        allow(config).to receive(:client_middleware)
        allow(Sidekiq).to receive(:configure_server).and_yield(config)

        expect(server_chain).to receive(:remove)
                                  .with(described_class::Middleware::Server)
        expect(server_chain).to receive(:add)
                                  .with(described_class::Middleware::Server,
                                        an_instance_of(
                                          described_class::Configuration
                                        ))

        described_class.register
      end

      it 'should register client middleware' do
        client_chain = double('Sidekick::MiddlewareChain')
        config = double('Sidekiq')
        allow(config).to receive(:server_middleware)
        allow(config).to receive(:client_middleware).and_yield(client_chain)
        allow(Sidekiq).to receive(:configure_server).and_yield(config)

        expect(client_chain).to receive(:remove)
                                  .with(described_class::Middleware::Client)
        expect(client_chain).to receive(:add)
                                  .with(described_class::Middleware::Client,
                                        an_instance_of(
                                          described_class::Configuration
                                        ))

        described_class.register
      end
    end

    context 'when sidekiq not run as a server' do
      it 'should register client middleware' do
        client_chain = double('Sidekick::MiddlewareChain')
        config = double('Sidekiq')
        allow(config).to receive(:client_middleware).and_yield(client_chain)
        allow(Sidekiq).to receive(:configure_client).and_yield(config)

        expect(client_chain).to receive(:remove)
                                  .with(described_class::Middleware::Client)
        expect(client_chain).to receive(:add)
                                  .with(described_class::Middleware::Client,
                                        an_instance_of(
                                          described_class::Configuration
                                        ))

        described_class.register
      end
    end
  end
end
