require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Collector do
  Given(:collector) { JRuby::Lint::Collector.new }
  Given(:checker_class) { Class.new { include JRuby::Lint::Checker } }

  context "loads detected checkers" do
    When { checker_class }
    Then { expect(collector.checkers.detect {|c| checker_class === c }).to be_truthy }
  end

  context "invokes all checkers" do
    Given(:checker) do
      double("checker").tap do |checker|
        expect(checker).to receive(:visitTrueNode)
        collector.checkers = [checker]
      end
    end
    When { collector.contents = 'true' }
    Then { collector.run }
  end

  context "reports syntax errors as findings" do
    When { collector.contents = '<% true %>' }
    When { collector.run }
    Then { expect(collector.findings.size).to eq(1) }
  end
end
