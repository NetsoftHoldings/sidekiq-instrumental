require 'spec_helper'

RSpec.describe Sidekiq::Instrumental do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  describe '::config' do
    describe '::config' do
      it 'should return a Configuration object' do
        expect(described_class.config).to be_an_instance_of(described_class::Configuration)
      end
    end
  end


  describe '::register' do
    it 'should register server middleware' do
      allow(Sidekiq).to receive(:configure_client)
      allow(Sidekiq).to receive(:server?).and_return(true)
      allow_any_instance_of(Sidekiq::Middleware::Chain).to receive(:add)
      expect_any_instance_of(Sidekiq::Middleware::Chain).to receive(:add).with(described_class::Middleware::Server, an_instance_of(described_class::Configuration))

      described_class.register
    end

    it 'should register client middleware' do
      allow(Sidekiq).to receive(:configure_server)
      expect_any_instance_of(Sidekiq::Middleware::Chain).to receive(:add).with(described_class::Middleware::Client, an_instance_of(described_class::Configuration))

      described_class.register
    end
  end
end
