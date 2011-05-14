module JRuby::Lint
  module Collectors
    class Gemspec < Collector
      def self.detect?(f)
        File.extname(f) == '.gemspec'
      end
    end
  end
end
