module JRuby::Lint
  class Finding < Struct.new(:message, :tags, :file, :line)
    def initialize(*args)
      if args.length > 2 && args[2].respond_to?(:file) && args[2].respond_to?(:line)
        args = [args[0], args[1], args[2].file, args[2].line]
      end
      super
    end

    def to_s
      "#{file}:#{line}: [#{tags.join(', ')}] #{message}"
    end
  end
end
