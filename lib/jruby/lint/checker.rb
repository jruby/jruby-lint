# Any class with this module included in it will be loaded as a
# checker.
module JRuby::Lint::Checker
  def self.included(cls)
    loaded_checkers << cls
  end

  def self.loaded_checkers
    @checkers ||= []
  end
end
