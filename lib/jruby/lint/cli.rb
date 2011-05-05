module JRuby
  module Lint
    class CLI
      def initialize(args)
        process_options(args)
      end

      def process_options(args)
        require 'optparse'
        OptionParser.new do |opts|
          opts.banner = "Usage: jruby-lint [options] [files]"
          opts.separator ""
          opts.separator "Options:"

          opts.on_tail("-h", "--help", "This message") do
            puts opts
            exit
          end
        end.parse!(args)
      end

      def run
        exit
      end
    end
  end
end
