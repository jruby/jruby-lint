module JRuby
  module Lint
    class CLI
      attr_reader :options

      def initialize(args)
        process_options(args)
      end

      def process_options(args)
        require 'optparse'
        require 'ostruct'
        @options = OpenStruct.new
        OptionParser.new do |opts|
          opts.banner = "Usage: jrlint [options] [files]"
          opts.separator ""
          opts.separator "Options:"

          opts.on('-C', '--chdir DIRECTORY', "Change working directory") do |v|
            Dir.chdir(v)
          end

          opts.on("-e", '--eval SCRIPT', "Lint an inline script") do |v|
            @options.eval ||= []
            @options.eval << v
          end

          opts.on("-t", "--tag TAG", "Report findings tagged with TAG") do |v|
            @options.tags ||= []
            @options.tags << v
          end

          opts.on('--text', 'print report as text') do
            @options.text = true
          end

          opts.on('--ansi', 'print report as ansi text') do
            @options.ansi = true
          end

          opts.on('--html [REPORT_FILE]', 'print report as html file') do |file|
            @options.html = file || 'jruby-lint.html'
          end

          opts.on_tail("-v", "--version", "Print version and exit") do
            require 'jruby/lint/version'
            puts "JRuby-Lint version #{VERSION}"
            exit
          end

          opts.on_tail("-h", "--help", "This message") do
            puts opts
            exit
          end
        end.parse!(args)

        @options.files = args.empty? ? nil : args
      end

      def run
        require 'jruby/lint'
        require 'benchmark'
        project = JRuby::Lint::Project.new(@options)

        puts "JRuby-Lint version #{JRuby::Lint::VERSION}"
        time = Benchmark.realtime { project.run }
        term = @options.eval ? 'expression' : 'file'
        puts "Processed #{project.files.size} #{term}#{project.files.size == 1 ? '' : 's'} in #{'%0.02f' % time} seconds"

        if project.findings.empty?
          puts "OK"
          exit
        else
          puts "Found #{project.findings.size} items"
          exit 1
        end
      end
    end
  end
end
