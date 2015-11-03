require "json"

module NameTaggedCeeSyslogger
  class CeeFormatter
    # This method is invoked when a log event occurs.
    def call(severity, timestamp, progname, msg)
      payload = {
        severity: ::Logger::SEV_LABEL[severity.first]
      }

      if msg.is_a?(Hash)
        payload.merge!(msg)
      else
        payload[:msg] = msg
      end

      "@cee: #{JSON.dump(payload)}"
    end

    # because ActiveJob looks here for tags
    def current_tags
      []
    end
  end
end
