[![Gem Version](https://badge.fury.io/rb/sidekiq-instrumental.svg)](https://badge.fury.io/rb/sidekiq-instrumental)

# Sidekiq::Instrumental

sidekiq-instrumental is a simple gem to record Sidekiq queue stats into [Instrumental](https://instrumentalapp.com/).

This gem is inspired by the [librato-sidekiq](https://github.com/StatusPage/librato-sidekiq/) gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-instrumental'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-instrumental

## Usage

After you configue Instrumental simply configure Sidekiq::Instrumental with the reference to your agent object.

```ruby
I = Instrumental::Agent.new(
    ENV['INSTRUMENTAL_KEY'],
    enabled: ENV['INSTRUMENTAL_KEY'].present?
)
# now tell Sidekiq::Instrumental what agent connection to use
Sidekiq::Instrumental.configure do |config|
  config.instrumental_agent = I
end
```

## Configuration

**NOTE** Make all configuration changes through the `.configure` block.

enabled: Boolean, true by default

**instrumental_agent**: the Instrumental::Agent instance to use to submit metrics 

**enabled**: Boolean, true by default

**whitelist_queues**: Array, list of queue names that will be the only ones sent to Instrumental (optional)

**blacklist_queues**: Array, list of queue names that will not be sent to Instrumental (optional)

**whitelist_classes**: Array, list of worker classes that will be the only ones sent to Instrumental (optional)

**blacklist_classes**: Array, list of worker classes that will not be sent to Instrumental (optional)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NetsoftHoldings/sidekiq-instrumental.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
