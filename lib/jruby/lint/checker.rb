# Any class with this module included in it will be loaded as a
# checker.
module JRuby::Lint::Checker
  def self.included(cls)
    checkers << cls
  end

  def self.checkers
    @checkers ||= []
  end
end
