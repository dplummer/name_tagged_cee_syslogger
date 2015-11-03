require "syslogger"
module NameTaggedCeeSyslogger
  class Logger < Syslogger
    def initialize(*args)
      super
      @formatter = CeeFormatter.new
    end
  end
end
