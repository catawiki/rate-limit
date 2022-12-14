# RateLimit
![rspec](https://github.com/catawiki/rate-limit/actions/workflows/main.yml/badge.svg) 

Protect your Ruby apps from bad actors. RateLimit allows you to set permissions as to whether certain number of feature calls are valid or not for a specific entity (user, phone number, email address, etc...). 

This gem mainly provides brute-force protection by throttling attempts for a specific entity id (i.e user_id). However it could also be used to throttle based on ip address (we recommend that you consider using [Rack::Attack](https://github.com/rack/rack-attack) for more optimized ip throttling)

#### Common Use Cases
* [Login] Brute-force attempts for a spefic account
* [SMS Spam] Brute-force attempts for requesting Phone Verification SMS for a specific user_id
* [SMS Spam] Brute-force attempts for requesting  Phone Verification SMS for a specific phone_number
* [Verifications] Brute-force attempts for entering verification codes
* [Redeem] Brute-force attempts to redeem voucher codes from a specific account

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rate-limit'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rate-limit

## Basic Usage

### [`RateLimit.throttle`](https://github.com/catawiki/rate-limit/wiki/Throttling)
The throttle method expects the following options

| Option           | Description                                                                     | Examples                              |
| ---------------- | ------------------------------------------------------------------------------- | ------------------------------------- |
| topic            | The topic you would like to throttle                                            | "login", "send_sms", "redeem_voucher" |
| value            | The identifier of the unique entity that is throttled based on the topic limits | user_id, phone_number, voucher_code   |


The `throttle` method checks if the given value did exceed the defined limits for the given topic. If the limit is exceeded then it returns [RateLimit::Result](https://github.com/catawiki/rate-limit/wiki/RateLimit::Result) Object, where `result.success?` will be `false`. Otherwise, it increments the attempts counter in the cache and sets `result.success?` to `true`.

#### Example
```ruby
result = RateLimit.throttle(topic: :login, value: 123)

if result.success?
  # Do something
end
```


Please check the [Wiki](https://github.com/catawiki/rate-limit/wiki) for advanced throttling and options.

## [Configuration](https://github.com/catawiki/rate-limit/wiki/Configuration)

Customize the configuration by adding the following block to `config/initializers/rate_limit.rb`

```ruby
RateLimit.configure do |config|
  config.redis             = Redis.new
  config.fail_safe         = true
  config.default_interval  = 60
  config.default_threshold = 2
  config.limits_file_path  = 'config/rate-limit.yml'
  config.on_success = proc { |result|
    # Success Logic Goes HERE
    # result.topic, result.value
  }
  config.on_failure = proc { |result|
    # Failure Logic Goes HERE
    # result.topic, result.value,  result.threshold,  result.interval
  }
end
```

#### Define Limits

The `config/rate-limit.yml` should include the limits you want to enforce on each given topic. In the following format:

```yaml
topic:
  threshold: interval
```

##### Example

* maximum `2` login attempts per `60` seconds
* maximum `1` send sms attempts per `60` seconds
* maximum `5` send sms attempts per `300` seconds
* maximum `10` send sms attempts per `3000` seconds

```yaml
login:
  2: 60
send_sms:
  1: 60
  5: 300
  10: 3000
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/catawiki/rate-limit. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/catawiki/rate-limit/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RateLimit project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/catawiki/rate-limit/blob/master/CODE_OF_CONDUCT.md).
