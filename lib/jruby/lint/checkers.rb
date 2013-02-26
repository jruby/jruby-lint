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
require 'jruby/lint/checkers/timeout'
require 'jruby/lint/checkers/system'
require 'jruby/lint/checkers/nonatomic'
