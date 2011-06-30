module JRuby::Lint
  class Finding < Struct.new(:message, :tags, :file, :line)
    def initialize(*args)
      args[1].map! {|x| x.to_s } if args.size > 1
      if args.size > 2 && args[2].respond_to?(:file) && args[2].respond_to?(:line)
        args = [args[0], args[1], args[2].file, (args[2].line + 1)]
      end
      super
    end

    def error?
      tags.include?('error')
    end

    def warning?
      tags.include?('warning')
    end

    def to_s
      "#{file}:#{line}: [#{tags.join(', ')}] #{message}"
    end
  end
end
