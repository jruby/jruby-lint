module JRuby::Lint
  module Collectors
    class Bundler < Collector
      def self.detect?(f)
        File.basename(f) == 'Gemfile'
      end
    end
  end
end
