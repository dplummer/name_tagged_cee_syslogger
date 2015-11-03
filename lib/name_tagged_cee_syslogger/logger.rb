require "syslogger"
module NameTaggedCeeSyslogger
  class Logger < Syslogger
    def initialize(*args)
      super
      @formatter = CeeFormatter.new
    end

    # wraps message with merge_tags
    def add(severity, message = nil, progname = nil, &block)
      if message.nil? && block.nil? && !progname.nil?
        message, progname = progname, nil
      end
      message = merge_tags(message || block && block.call)

      super(severity, message, progname)
    end

    # prevent default tag behavior
    def tags_text
      ""
    end

    def merge_tags(message)
      unless message.is_a?(Hash)
        message = { msg: message }
      end

      current_tags.each_with_index do |tag, index|
        if tag.is_a?(Hash)
          message.merge!(tag)
        end
      end

      message
    end
  end
end
