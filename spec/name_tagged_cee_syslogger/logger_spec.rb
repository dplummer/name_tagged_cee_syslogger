require "spec_helper"

describe NameTaggedCeeSyslogger::Logger do
  let(:syslog) { double("syslog", :mask= => true) }

  before do
    expect(Syslog).to receive(:open).
      with($0, Syslog::LOG_PID | Syslog::LOG_CONS, nil).
      and_yield(syslog)
  end

  it "logs simple messages" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","msg":"Some message"}')

    subject.warn "Some message"
  end

  it "logs message hashes as data" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","foo":"bar","baz":123}')

    subject.warn(foo: "bar", baz: 123)
  end

  it "tags log messages" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","mytag":"yarp","foo":"bar","baz":123}')

    subject.tagged(mytag: "yarp") do
      subject.warn(foo: "bar", baz: 123)
    end
  end

  it "lets the message override a tag" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","foo":"it is new foo!"}')

    subject.tagged(foo: "tag") do
      subject.warn(foo: "it is new foo!")
    end
  end

  it "lets the message override a tag, tag has a string key" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","foo":"it is new foo!"}')

    subject.tagged("foo" => "tag") do
      subject.warn(foo: "it is new foo!")
    end
  end

  it "lets the message override a tag, message has a string key" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","foo":"it is new foo!"}')

    subject.tagged(foo: "tag") do
      subject.warn("foo" => "it is new foo!")
    end
  end

  it "ignores any tag that isn't a hash" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","foo":"bar"}')

    subject.tagged("yarp") do
      subject.warn(foo: "bar")
    end
  end

  it "can nest tagging" do
    expect(syslog).to receive(:log).
      with(Syslog::LOG_WARNING, '@cee: {"severity":"WARN","tag":"2","foo":"bar"}')

    subject.tagged("tag" => "1") do
      subject.tagged("tag" => "2") do
        subject.warn(foo: "bar")
      end
    end
  end

end
