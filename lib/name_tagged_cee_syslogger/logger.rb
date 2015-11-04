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
      if message.is_a?(Hash)
        message = message.each_with_object({}) do |(k,v), acc|
          acc[k.to_sym] = v
        end
      else
        message = { msg: message }
      end

      message = current_tags.merge(message)

      message
    end

    def tagged(tags, *_)
      old_tags = current_tags.dup

      begin
        add_tags(tags)
        yield self
      ensure
        set_tags(old_tags)
      end
    end

    private

    def add_tags(tags)
      return unless tags.is_a?(Hash)

      tags.each do |(k,v)|
        current_tags[k.to_sym] = v
      end
    end

    def set_tags(tags)
      clear_tags!
      add_tags(tags)
    end

    def current_tags
      Thread.current[:name_tagged_logger_tags] ||= {}
    end
  end
end
