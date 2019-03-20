# Any class with this module included in it will be loaded as a
# checker.
module JRuby::Lint
  module Checker
    def self.included(cls)
      loaded_checkers << cls
    end

    def self.loaded_checkers
      @checkers ||= []
    end

    # Note: for parentage methods below -1 is current visited, -2 is parent ,...

    ##
    # What is parent during visit of the current node being visited.
    def parent
      collector.stack.size >= 2 ? collector.stack[-2] : nil 
    end

    def grand_parent
      collector.stack.size >= 3 ? collector.stack[-3] : nil 
    end

    attr_accessor :collector
  end

  module Checkers
  end
end

require 'jruby/lint/checkers/fork_exec'
require 'jruby/lint/checkers/gem'
require 'jruby/lint/checkers/gemspec'
require 'jruby/lint/checkers/thread_critical'
require 'jruby/lint/checkers/object_space'
require 'jruby/lint/checkers/system'
require 'jruby/lint/checkers/nonatomic'
