require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Collector do
  Given(:collector) { JRuby::Lint::Collector.new }
  Given(:checker_class) { Class.new { include JRuby::Lint::Checker } }

  it "loads detected checkers" do
    checker_class
    collector.checkers.detect {|c| checker_class === c }.should be_true
  end

  Given(:checker) { mock("checker").tap {|checker| collector.checkers = [checker] } }

  it "invokes all checkers" do
    checker.should_receive(:check).with(collector)
    collector.run
  end

  Given(:reporter) { mock("reporter").tap {|reporter| collector.reporters = [reporter] } }
  Given(:finding) { mock "finding" }

  it "reports all findings" do
    checker.stub!(:check).and_return do
      collector.findings << finding
    end
    reporter.should_receive(:report).with([finding])

    collector.run
  end

end
