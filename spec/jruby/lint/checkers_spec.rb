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
  Given(:gems) { { "rdiscount" => "may not work" } }
  Given(:gems_info) { double "gem info", :gems => gems }
  Given(:project) { double "project", :gems_info => gems_info }
  Given(:collector) { double "collector", :ast => ast, :findings => findings, :project => project }

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

  context "Gem checker" do
    Given(:checker) { JRuby::Lint::Checkers::Gem.new }

    context "creates a finding for a gem mentioned in the gems info" do
      Given(:script) { "gem 'rdiscount'" }
      When { checker.check(collector) }
      Then { findings.size.should == 1 }
    end

    context "does not create a finding for a gem not mentioned in the gems info" do
      Given(:script) { "gem 'json_pure'" }
      When { checker.check(collector) }
      Then { findings.size.should == 0 }
    end
  end

  context "Gemspec checker" do
    Given(:checker) { JRuby::Lint::Checkers::Gemspec.new }

    Given(:script) { "Gem::Specification.new do |s|" +
      "\ns.name = 'hello'\ns.add_dependency 'rdiscount'\n" +
      "s.add_development_dependency 'ruby-debug19'\nend\n" }
    When { checker.check(collector) }
    Then { findings.size.should == 1 }
    Then { findings.first.message.should =~ /rdiscount/ }
  end
end
