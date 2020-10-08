# Rpi::Dht

Written purly in Ruby (except external gems)!

## datasheet references

- [dht11][1]
- [dht22][2]

## Installation

Add this line to your application's Gemfile:

```rb
gem "rpi-dht"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rpi-dht

## Usage

```rb
require "rpi/dht"

pin = 4 # bcm number https://i.gyazo.com/8de74c9e6a7139e30c2f540715a24dc9.png

####################
# GPIO numbering
####################
# RPi::Dht.set_numbering(:bcm)        [default]
# or RPi::Dht.set_numbering(:board)

# Because it can't receive valid data from sensor reliably, there are methods try to read continusly until it gets valid data
# [read_11 and read_22] (without !) are recommended

####################
# for DHT11 sensor
####################
RPi::Dht.read_11!(pin) # raises exception, if you want to manage by yourself
# => returns e.g. {humidity: 12, temperature: 34, temperature_f: 93.2}
# or exception

RPi::Dht.read_11(pin, tries: 50) # tries 50 times and doesn't raise
# or RPi::Dht.read_11(pin) defaults to 50 tries
# => returns e.g. {humidity: 12, temperature: 34, temperature_f: 93.2}
# or nil if it doesn't get valid data

####################
# for DHT22 sensor
####################
RPi::Dht.read_22!(pin) # raises exception, if you want to manage by yourself
# => returns e.g. {humidity: 12.3, temperature: 34.5, temperature_f: 94.1}
# or exception

RPi::Dht.read_22(pin, tries: 50) # tries 50 times and doesn't raise
# or RPi::Dht.read_22(pin) defaults to 50 tries
# => returns e.g. {humidity: 12.3, temperature: 34.5, temperature_f: 94.1}
# or nil if it doesn't get valid data
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/github0013/rpi-dht.

[1]: https://akizukidenshi.com/download/ds/aosong/DHT11.pdf
[2]: https://akizukidenshi.com/download/ds/aosong/AM2302.pdf
