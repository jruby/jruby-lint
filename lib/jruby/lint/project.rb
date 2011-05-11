require 'set'
module JRuby::Lint
  class Project
    DEFAULT_TAGS = %w(error warning info)

    attr_reader :collectors, :reporters, :findings, :files, :tags

    def initialize
      @tags = DEFAULT_TAGS
      @collectors = load_collectors
      @reporters = [Reporters::Text.new(self, STDOUT)]
    end

    def run
      @findings = []
      collectors.each {|c| c.run }
      collectors.each {|c| @findings += c.findings }
      reporters.each {|r| r.report(@findings)}
    end

    private
    def load_collectors
      @files = Set.new
      [].tap do |collectors|
        Dir['./**/*'].each do |f|
          next unless File.file?(f)
          Collector.all.each do |c|
            if c.detect?(f)
              collectors << c.new(f)
              @files << f
            end
          end
        end
      end
    end
  end
end
