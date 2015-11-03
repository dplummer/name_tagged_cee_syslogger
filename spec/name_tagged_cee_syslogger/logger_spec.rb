require "spec_helper"

describe NameTaggedCeeSyslogger::Logger do
  let(:syslog) { double("syslog", :mask= => true) }

  it "logs simple messages" do
    expect(Syslog).to receive(:open).
      with($0, Syslog::LOG_PID | Syslog::LOG_CONS, nil).
      and_yield(syslog)
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","msg":"Some message"}')

    subject.warn "Some message"
  end
end
