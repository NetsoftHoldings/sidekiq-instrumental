require 'spec_helper'

RSpec.describe Sidekiq::Instrumental do
  it 'has a version number' do
    expect(Sidekiq::Instrumental::VERSION).not_to be nil
  end
end
