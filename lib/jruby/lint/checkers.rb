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

  module FileChecker
    attr_reader :file
    def initialize(filename)
      @file = filename
    end

    def contents
      File.read(@file)
    end
  end
end
