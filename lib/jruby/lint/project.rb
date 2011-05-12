require 'set'
require 'ostruct'

module JRuby::Lint
  class Project
    DEFAULT_TAGS = %w(error warning info)

    attr_reader :collectors, :reporters, :findings, :files, :tags, :gems_info

    def initialize(options = OpenStruct.new)
      @tags = DEFAULT_TAGS
      @collectors = []
      @files = Set.new

      if options.eval
        options.eval.each {|e| @collectors << JRuby::Lint::Collectors::Ruby.new(self, '-e', e) }
        @files += @collectors
      end

      @sources = options.files || (options.eval ? [] : Dir['./**/*'])
      load_collectors
      load_reporters
      load_gems_info
    end

    def run
      @findings = []
      collectors.each do |c|
        c.run
        reporters.each {|r| r.report(c.findings)}
        @findings += c.findings
      end
    end

    private
    def load_collectors
      @sources.each do |f|
        next unless File.file?(f)
        Collector.all.each do |c|
          if c.detect?(f)
            @collectors << c.new(self, f)
            @files << f
          end
        end
      end
    end

    def load_reporters
      @reporters = [(STDOUT.tty? ? Reporters::ANSIColor : Reporters::Text).new(self, STDOUT)]
    end

    def load_gems_info
      @gems_info = Gems::Info.new(Gems::Cache.new)
    end
  end
end
