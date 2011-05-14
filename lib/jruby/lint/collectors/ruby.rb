module JRuby::Lint
  module Collectors
    class Ruby < Collector
      def initialize(project, file, contents = nil)
        super(project, file)
        @contents = contents
      end

      def self.detect?(f)
        File.extname(f) == '.rb'
      end
    end
  end
end
