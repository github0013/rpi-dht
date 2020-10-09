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

## OR ...

    $ uname -a
    Linux rpi16gb 5.4.51+ #1333 Mon Aug 10 16:38:02 BST 2020 armv6l GNU/Linux

    $ lsb_release -a
    No LSB modules are available.
    Distributor ID:	Raspbian
    Description:	Raspbian GNU/Linux 10 (buster)
    Release:	10
    Codename:	buster

    $ cat /proc/cpuinfo
    processor	: 0
    model name	: ARMv6-compatible processor rev 7 (v6l)
    BogoMIPS	: 697.95
    Features	: half thumb fastmult vfp edsp java tls
    CPU implementer	: 0x41
    CPU architecture: 7
    CPU variant	: 0x0
    CPU part	: 0xb76
    CPU revision	: 7

    Hardware	: BCM2835
    Revision	: 0010
    Serial		: 000000005f8c6a39
    Model		: Raspberry Pi Model B Plus Rev 1.2

I am using a Raspberry Pi Model B Plus Rev 1.2 (fairly old) and it takes significant amount of time to read.

### Sample source code

```rb
# read.rb
require "benchmark"
require "rpi/dht"
PIN = 4

Benchmark.bm 10 do |r|
  r.report "reading 10 times" do
    10.times { RPi::Dht.read_22(PIN) }
  end
end
```

    $ time ruby read.rb
                    user     system      total        real
    reading 10 times  2.025668   0.022232   2.047900 ( 55.610802)
    ruby read.rb  4.62s user 0.52s system 8% cpu 58.773 total

### Solution

I just found there is **a device tree overlay for DHT11/22**. If you set this up, you can just read system files to read humidity and temperature.

    $ cat /sys/bus/iio/devices/iio\:device0/in_humidityrelative_input
    43300

    $ cat /sys/bus/iio/devices/iio\:device0/in_temp_input
    27100

### Setup

1. take the SD card from your Raspberry Pi
1. edit /boot/config on your computer
1. add `dtoverlay=dht11` at the bottom
1. set the SD card back to your Raspberry Pi
1. run `lsmod | grep dht`, and you should see something like this
   - `dht11 16384 0`
1. run `cat /sys/bus/iio/devices/iio\:device0/in_humidityrelative_input` for humidity, then devide the number by 1000
1. run `cat /sys/bus/iio/devices/iio\:device0/in_temp_input` for temperature, then devide the number by 1000

It sometimes gives `Connection timed out` error, so maybe you can write something like this.

```rb
require "pathname"

def read_humidity
  Pathname("/sys/bus/iio/devices/iio\:device0/in_humidityrelative_input").read.to_f / 1000
rescue => ex
  sleep 0.5
  retry
end

def read_temperature
  Pathname("/sys/bus/iio/devices/iio\:device0/in_temp_input").read.to_f / 1000
rescue => ex
  sleep 0.5
  retry
end
```

bang!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/github0013/rpi-dht.

[1]: https://akizukidenshi.com/download/ds/aosong/DHT11.pdf
[2]: https://akizukidenshi.com/download/ds/aosong/AM2302.pdf
