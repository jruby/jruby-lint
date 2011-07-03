module JRuby::Lint
  module Reporters
    class Html
      require 'erb'

      def initialize(project, output)
        @tags = project.tags
        @output = output
        @template = ERB.new(File.read(File.expand_path('../jruby-lint.html.erb', __FILE__)))
      end

      def report(findings)
      end

      def print_report(findings)
        @findings = []
        findings.each do |finding|
          @findings << finding unless (@tags & finding.tags).empty?
        end

        File.open(@output, 'w') do |file|
          file.write @template.result(binding)
        end
      end
    end
  end
end
