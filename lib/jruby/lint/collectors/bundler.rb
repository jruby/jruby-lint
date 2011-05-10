module JRuby::Lint
  module Collectors
    class Bundler < Collector
      include ASTCollector
      include FileCollector

      def self.detect?(f)
        File.basename(f) == 'Gemfile'
      end
    end
  end
end
