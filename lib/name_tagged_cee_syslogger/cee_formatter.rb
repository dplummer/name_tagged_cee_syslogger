require "json"
require "logger"

module NameTaggedCeeSyslogger
  class CeeFormatter
    # This method is invoked when a log event occurs.
    def call(severity, _timestamp, _progname, msg)
      friendly_severity = severity.is_a?(String) ? severity : ::Logger::SEV_LABEL[severity.first]

      payload = {
        severity: friendly_severity
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
