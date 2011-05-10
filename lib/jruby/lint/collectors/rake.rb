module JRuby::Lint
  module Collectors
    class Rake < Collector
      include ASTCollector
      include FileCollector

      def self.detect?(f)
        File.basename(f) == 'Rakefile' || File.extname(f) == '.rake'
      end
    end
  end
end
