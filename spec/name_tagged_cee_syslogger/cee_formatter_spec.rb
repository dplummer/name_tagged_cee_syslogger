require "spec_helper"

describe NameTaggedCeeSyslogger::CeeFormatter do
  it "converts a severity constant to a friendly name" do
    expect(subject.call([::Logger::WARN], Time.now, "myapp", "Some message")).
      to eq('@cee: {"severity":"WARN","msg":"Some message"}')
  end

  it "does no conversion when the severity is a string" do
    expect(subject.call("INFO", Time.now, "myapp", "Some message")).
      to eq('@cee: {"severity":"INFO","msg":"Some message"}')
  end
end
