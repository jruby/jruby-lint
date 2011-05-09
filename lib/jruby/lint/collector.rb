class JRuby::Lint::Collector
  attr_accessor :checkers, :reporters, :findings

  def initialize
    @checkers  = JRuby::Lint::Checker.loaded_checkers.map(&:new)
    @reporters = []
    @findings  = []
  end

  def run
    checkers.each {|c| c.check(self) }
    reporters.each {|r| r.report(findings)}
  end
end
