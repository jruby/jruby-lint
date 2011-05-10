module JRuby::Lint
  class Collector
    attr_accessor :checkers, :findings

    def initialize
      @checkers  = Checker.loaded_checkers.map(&:new)
      @findings  = []
    end

    def run
      checkers.each {|c| c.check(self) }
    end

    def self.inherited(base)
      self.all << base
    end

    def self.all
      @collectors ||= []
    end
  end

  module FileCollector
    attr_reader :file

    def initialize(filename)
      @file = filename
    end

    def contents
      File.read(@file)
    end
  end

  module ASTCollector
    attr_reader :contents

    def initialize(script)
      @contents = script
    end

    def file
      '<inline-script>'
    end

    def ast
      @ast ||= JRuby.parse(contents, file, true)
    end
  end

  module Collectors
  end
end

require 'jruby/lint/collectors/ruby'
require 'jruby/lint/collectors/bundler'
require 'jruby/lint/collectors/rake'
require 'jruby/lint/collectors/gemspec'
