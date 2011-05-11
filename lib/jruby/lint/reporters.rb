module JRuby::Lint
  module Reporters
    class Text
      def initialize(project, output)
        @tags, @output = project.tags, output
      end

      def report(findings)
        findings.each do| f|
          @output.puts f.to_s unless (@tags & f.tags).empty?
        end
      end
    end
  end
end
