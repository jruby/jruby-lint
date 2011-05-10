module JRuby::Lint
  module Reporters
    class Text
      def initialize(output)
        @output = output
      end

      def report(findings)
        findings.each {|f| @output.puts f.to_s }
      end
    end
  end
end
