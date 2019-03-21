module JRuby::Lint
  module Reporters
    class Text
      def initialize(project, output, options=OpenStruct.new)
        @tags, @output, @options = project.tags, output, options
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
                cyan(finding.to_s)
              else
                blue(finding.to_s)
              end
        @output.puts msg
        @output.puts finding.src_line if finding.src_line && !@options.no_src_line
      end
    end
  end
end
