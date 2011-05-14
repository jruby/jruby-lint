module JRuby::Lint
  module Collectors
    class Rake < Collector
      def self.detect?(f)
        File.basename(f) == 'Rakefile' || File.extname(f) == '.rake'
      end
    end
  end
end
