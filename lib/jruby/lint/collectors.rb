module JRuby::Lint
  class Collector
    attr_accessor :checkers, :findings, :project, :contents, :file, :stack

    def initialize(project = nil, file = nil)
      @checkers = Checker.loaded_checkers.map(&:new)
      @checkers.each {|c| c.collector = self }
      @findings = []
      @project, @file = project, file || '<inline-script>'

      # top to bottom list of elements as they are visited
      @stack = [] # FIXME: ast visiting is not something checkers can see so stored here for now
    end

    def add_finding(message, tags, line=nil)
      puts caller if (line == "1") 
      src_line = line ? contents.split(/\n/)[line-1] : nil
      @findings << Finding.new(message, tags, file, line, src_line)
    end

    class CheckersVisitor < AST::Visitor
      attr_reader :collector, :checkers, :stack


      def initialize(ast, collector, checkers)
        super(ast)
        @collector, @checkers = collector, checkers
      end

      def visit(method, node)
        @collector.stack.push  node
        after_hooks = []
        checkers.each do |ch|
          begin
            if ch.respond_to?(method)
              res = ch.send(method, node)
              after_hooks << res if res.respond_to?(:call)
            end
          rescue Exception => e
            collector.add_finding("Exception while traversing: #{e.message}\n  at #{e.backtrace.first}",
                                              [:internal, :debug], node.line+1)
          end
        end
        super
      rescue Exception => e
        collector.add_finding("Exception while traversing: #{e.message}\n  at #{e.backtrace.first}",
                                          [:internal, :debug], node.line+1)
      ensure
        begin
          after_hooks.each {|h| h.call }
        rescue
        end
        @collector.stack.pop
      end
    end

    def run
      begin
        CheckersVisitor.new(ast, self, checkers).traverse
      rescue SyntaxError => e
        file, line, message = e.message.split(/:\s*/, 3)
        add_finding(message, [:syntax, :error], line.to_i)
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
