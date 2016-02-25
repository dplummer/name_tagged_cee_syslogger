require "syslogger"
require "thread"

module NameTaggedCeeSyslogger
  class Logger < Syslogger
    class ThreadEmptyError < ThreadError
      def self.===(exception)
        exception.is_a?(ThreadError) && exception.message == "queue empty"
      end
    end

    def initialize(*args)
      super
      @formatter = CeeFormatter.new
      @message_queue = Queue.new
      @queue_worker = Thread.new do
        loop do
          process_queue
        end
      end
    end

    def queue_length
      @message_queue.length
    end

    def stop
      kill
      while process_queue(true); end
    rescue ThreadEmptyError
    end

    def kill
      @queue_worker.kill if @queue_worker
    end

    def process_queue(non_block=true)
      log_message = @message_queue.pop(non_block)
      add_now log_message.severity, log_message.message, log_message.progname
      log_message
    end

    alias_method :add_now, :add

    LogMessage = Struct.new(:severity, :message, :progname)

    # wraps message with merge_tags
    def add(severity, message = nil, progname = nil, &block)
      if message.nil? && block.nil? && !progname.nil?
        message, progname = progname, nil
      end
      message = merge_tags(message || block && block.call)

      enqueue_add(severity, message, progname)
    end

    def enqueue_add(severity, message, progname)
      @message_queue.push LogMessage.new(severity, message, progname)
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
