# NameTaggedCeeSyslogger

Like using Syslogger, TaggedLogging, and Lograge with the CeeFormatter. But For
general purpose Rails use. Plus the tags get named so they are filterable in
Kibana.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'name_tagged_cee_syslogger'
```

## Usage

Add do your rails configuration:

```ruby
config.logger = NameTaggedCeeSyslogger.new("YourAppName", Syslog::LOG_PID, Syslog::LOG_LOCAL7)
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/dplummer/name_tagged_cee_syslogger.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

