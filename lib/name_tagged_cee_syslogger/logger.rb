require "syslogger"
require "circular_queue"

module NameTaggedCeeSyslogger
  class Logger < Syslogger
    class ThreadEmptyError < ThreadError
      def self.===(exception)
        exception.is_a?(ThreadError) &&
          (exception.message == "queue empty" || exception.message == "Queue is empty")
      end
    end

    LogMessage = Struct.new(:severity, :message, :progname)

    attr_reader :async

    def initialize(ident = $0, options = Syslog::LOG_PID | Syslog::LOG_CONS, facility = nil, queue_options = {})
      super(ident, options, facility)
      @formatter = CeeFormatter.new
      @async = queue_options.fetch(:async, true)

      max_length = queue_options.fetch(:max_length, 1_000_000)

      if max_length > 0
        @message_queue = CircularQueue.new max_length
      else
        @message_queue = Queue.new
      end

      @queue_worker = Thread.new do
        process_queue
      end
    end

    def queue_length
      @message_queue.length
    end

    def stop
      kill
      process_queue(true)
    rescue ThreadEmptyError
    end

    def kill
      @queue_worker.kill if @queue_worker
    end

    alias_method :add_now, :add

    # wraps message with merge_tags
    def add(severity, message = nil, progname = nil, &block)
      if message.nil? && block.nil? && !progname.nil?
        message, progname = progname, nil
      end
      message = merge_tags(message || block && block.call)

      if async
        enqueue_add(severity, message, progname)
      else
        add_now(severity, message, progname)
      end
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

    def enqueue_add(severity, message, progname)
      @message_queue.push LogMessage.new(severity, message, progname)
    end

    def process_queue(non_block=true)
      loop do
        log_message = @message_queue.pop(non_block)
        add_now log_message.severity, log_message.message, log_message.progname
      end
    end
  end
end
