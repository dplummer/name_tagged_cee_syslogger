#!/usr/bin/env ruby

require "bundler/setup"
require "name_tagged_cee_syslogger"

require "benchmark"

class NameTaggedCeeSyslogger::Logger
  def add_now(*args)
    sleep 0.0000001
  end
end

sync = NameTaggedCeeSyslogger::Logger.new($0, Syslog::LOG_PID | Syslog::LOG_CONS, nil, async: false)
queue = NameTaggedCeeSyslogger::Logger.new($0, Syslog::LOG_PID | Syslog::LOG_CONS, nil, max_length: 0)
lcircle = NameTaggedCeeSyslogger::Logger.new($0, Syslog::LOG_PID | Syslog::LOG_CONS, nil, max_length: 1_000_000)
scircle = NameTaggedCeeSyslogger::Logger.new($0, Syslog::LOG_PID | Syslog::LOG_CONS, nil, max_length: 50)

N = 1_000_000

Benchmark.bm do |x|
  x.report('sync') { N.times { |n| sync.warn "message #{n}" } }
  x.report('queue') { N.times { |n| queue.warn "message #{n}" }; queue.stop }
  x.report('large circle') { N.times { |n| lcircle.warn "message #{n}" }; lcircle.stop }
  x.report('small circle') { N.times { |n| scircle.warn "message #{n}" }; scircle.stop }
end

# Macbook Pro Mid 2014 2.8GHz Core i7
#               user       system     total    real
# sync          3.140000   0.300000   3.440000 (  3.457583)
# queue         4.000000   0.450000   4.450000 (  4.444919)
# large circle  4.710000   0.330000   5.040000 (  5.049813)
# small circle  2.960000   0.000000   2.960000 (  2.972995)
