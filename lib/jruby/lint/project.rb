require 'set'
require 'ostruct'

module JRuby::Lint
  class Project
    DEFAULT_TAGS = %w(error warning info)

    attr_reader :collectors, :reporters, :findings, :files, :tags, :libraries

    def initialize(options = OpenStruct.new)
      @tags = DEFAULT_TAGS.dup
      @collectors = []
      @files = Set.new

      if options.eval
        options.eval.each {|e| @collectors << JRuby::Lint::Collectors::Ruby.new(self, '-e', e) }
        @files += @collectors
      end

      if options.tags
        @tags += options.tags
      end

      @sources = options.files || (options.eval ? [] : Dir['./**/*'])
      load_collectors
      load_reporters(options)
      load_libraries
    end

    def run
      @findings = []
      collectors.each do |c|
        c.run
        reporters.each {|r| r.report(c.findings)}
        @findings += c.findings
      end
      reporters.each {|r| r.print_report(@findings) if r.respond_to?(:print_report) }
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

    def load_reporters(options)
      @reporters = []
      @reporters << Reporters::Html.new(self, options.html) if options.html
      @reporters << Reporters::ANSIColor.new(self, STDOUT) if options.ansi || STDOUT.tty?
      @reporters << Reporters::Text.new(self, STDOUT) if options.text || @reporters.empty?
    end

    def load_libraries
      @libraries = Libraries.new(Libraries::Cache.new)
    end
  end
end
