# NameTaggedCeeSyslogger

Like using Syslogger, TaggedLogging, and Lograge with the CeeFormatter. But For
general purpose Rails use. Plus the tags get named so they are filterable in
Kibana.

Uses [syslogger](https://github.com/crohr/syslogger) gem, check it out for more
usage information.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'name_tagged_cee_syslogger'
```

## Usage

Add do your rails configuration:

```ruby
config.logger = NameTaggedCeeSyslogger::Logger.new("YourAppName", Syslog::LOG_PID, Syslog::LOG_LOCAL7)
```

```ruby
logger = NameTaggedCeeSyslogger::Logger.new("my_app", Syslog::LOG_PID | Syslog::LOG_CONS, Syslog::LOG_LOCAL0)
logger.level = ::Logger::INFO # use Logger levels
logger.warn "warning message"
logger.debug "debug message"

logger.info "my_subapp" { "Some lazily computed message" }
# => Nov  2 13:57:11 hostname my_subapp[21861]: @cee: {"msg":"Some lazily computed message","severity":"INFO"}

logger.tagged(tagname: "abc123") do
  logger.info "this is a message"
end
# => Nov  2 13:57:11 hostname my_app[21860]: @cee: {"tagname":"abc123","msg":"this is a message","severity":"INFO"}

logger.warn(a: "hash", of: "data")
# => Nov  2 13:57:11 hostname my_app[21860]: @cee: {"a":"hash","of":"data","severity":"WARN"}
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

