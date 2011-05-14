require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Collector do
  Given(:collector) { JRuby::Lint::Collector.new }
  Given(:checker_class) { Class.new { include JRuby::Lint::Checker } }

  context "loads detected checkers" do
    When { checker_class }
    Then { collector.checkers.detect {|c| checker_class === c }.should be_true }
  end

  context "invokes all checkers" do
    Given(:checker) do
      double("checker").tap do |checker|
        checker.should_receive(:visitTrueNode)
        collector.checkers = [checker]
      end
    end
    When { collector.contents = 'true' }
    Then { collector.run }
  end

  context "loads an AST" do
    When { collector.contents = 'puts "hello"' }
    When { @ast = collector.ast }
    Then { @ast.inspect.should =~ /"hello"/m }
  end

  context "reports syntax errors as findings" do
    When { collector.contents = '<% true %>' }
    When { collector.run }
    Then { collector.findings.size.should == 1 }
  end
end
