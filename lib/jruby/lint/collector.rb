module JRuby::Lint
  class Collector
    attr_accessor :checkers, :reporters, :findings

    def initialize
      @checkers  = Checker.loaded_checkers.map(&:new)
      @reporters = []
      @findings  = []
    end

    def run
      checkers.each {|c| c.check(self) }
      reporters.each {|r| r.report(findings)}
    end
  end
end
