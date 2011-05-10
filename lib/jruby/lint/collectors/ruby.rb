module JRuby::Lint
  module Collectors
    class Ruby < Collector
      include ASTCollector
      include FileCollector

      def self.detect?(f)
        File.extname(f) == '.rb'
      end
    end
  end
end
