require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Checker do
  context "checkers" do
    subject { Class.new { include JRuby::Lint::Checker } }

    it "finds all loaded checkers" do
      JRuby::Lint::Checker.checkers.should include(subject)
    end
  end
end
