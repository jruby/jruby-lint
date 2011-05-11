module JRuby::Lint
  module Collectors
    class Ruby < Collector
      include ASTCollector
      include FileCollector

      def initialize(file, contents = nil)
        super(file)
        @contents = contents
      end

      def self.detect?(f)
        File.extname(f) == '.rb'
      end
    end
  end
end
