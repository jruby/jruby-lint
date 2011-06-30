module JRuby::Lint
  module Reporters
    class Text
      def initialize(project, output)
        @tags, @output = project.tags, output
      end

      def report(findings)
        findings.each do |finding|
          puts finding unless (@tags & finding.tags).empty?
        end
      end

      def puts(finding)
        @output.puts finding.to_s
      end
    end

    class ANSIColor < Text
      require 'term/ansicolor'
      include Term::ANSIColor
      def puts(finding)
        msg = if finding.error?
                red(finding.to_s)
              elsif finding.warning?
                yellow(finding.to_s)
              else
                finding.to_s
              end
        @output.puts msg
      end
    end
  end
end
