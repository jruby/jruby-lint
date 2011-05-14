module JRuby::Lint
  class Collector
    attr_accessor :checkers, :findings, :project, :contents, :file

    def initialize(project = nil, file = nil)
      @checkers  = Checker.loaded_checkers.map(&:new)
      @checkers.each {|c| c.collector = self }
      @findings  = []
      @project, @file = project, file || '<inline-script>'
    end

    def run
      begin
        checkers.each {|c| c.check(self) }
      rescue SyntaxError => e
        file, line, message = e.message.split(/:\s*/, 3)
        findings << Finding.new(message, [:syntax, :error], file, line)
      end
    end

    def ast
      @ast ||= JRuby.parse(contents, file, true)
    end

    def contents
      @contents || File.read(@file)
    end

    def self.inherited(base)
      self.all << base
    end

    def self.all
      @collectors ||= []
    end
  end

  module Collectors
  end
end

require 'jruby/lint/collectors/ruby'
require 'jruby/lint/collectors/bundler'
require 'jruby/lint/collectors/rake'
require 'jruby/lint/collectors/gemspec'
