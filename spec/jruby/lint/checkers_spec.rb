require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Checker do
  context "checkers" do
    subject { Class.new { include JRuby::Lint::Checker } }

    it "finds all loaded checkers" do
      JRuby::Lint::Checker.loaded_checkers.should include(subject)
    end
  end
end

describe JRuby::Lint::Checkers do
  Given(:findings) { [] }
  Given(:ast) { JRuby.parse script }
  Given(:collector) { double("collector", :ast => ast, :findings => findings) }

  context "Fork/exec checker" do
    Given(:checker) { JRuby::Lint::Checkers::ForkExec.new }

    context "detects fcall-style" do
      # FCallNoArgBlockNode |fork|
      Given(:script) { "fork { }; exec('cmd')" }
      When { checker.check(collector) }
      Then { findings.size.should == 2 }
    end

    context "detects vcall-style" do
      # VCallNode |fork|
      Given(:script) { "fork" }
      When { checker.check(collector) }
      Then { findings.size.should == 1 }
    end

    context "does not detect call-style" do
      # CallNoArgNode |fork|
      #   VCallNode |fork|
      Given(:script) { "fork.fork" }
      When { checker.check(collector) }
      Then { findings.size.should == 0 }
    end

    context "detects Kernel::fork style" do
      # CallNoArgNode |fork|
      #   ConstNode |Kernel|
      Given(:script) { "Kernel::fork; Kernel::exec('cmd')" }
      When { checker.check(collector) }
      Then { findings.size.should == 2 }
    end
  end
end
