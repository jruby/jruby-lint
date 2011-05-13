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
  end

  module Checkers
  end
end

require 'jruby/lint/checkers/fork_exec'
require 'jruby/lint/checkers/gem'
require 'jruby/lint/checkers/gemspec'
