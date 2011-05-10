module JRuby::Lint
  module Collectors
    class Gemspec < Collector
      include ASTCollector
      include FileCollector

      def self.detect?(f)
        File.extname(f) == '.gemspec'
      end
    end
  end
end
