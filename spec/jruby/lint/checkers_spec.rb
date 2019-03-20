require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Checker do
  context "checkers" do
    subject { Class.new { include JRuby::Lint::Checker } }

    it "finds all loaded checkers" do
      expect(JRuby::Lint::Checker.loaded_checkers).to include(subject)
    end
  end
end

describe JRuby::Lint::Checkers do
  Given(:gems) { { "rdiscount" => "may not work", "bson_ext" => "not needed" } }
  Given(:project) {JRuby::Lint::Project.new.tap {|p| p.libraries.gems = gems }}
  Given(:collector) do
    JRuby::Lint::Collector.new(project).tap do |c|
      c.contents = script
      c.checkers = [checker]
      checker.collector = c
    end
  end

  context "Fork/exec checker" do
    Given(:checker) { JRuby::Lint::Checkers::ForkExec.new }

    context "detects fcall-style" do
      # FCallNoArgBlockNode |fork|
      Given(:script) { "fork { }" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "detects vcall-style" do
      # VCallNode |fork|
      Given(:script) { "fork" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "does not detect call-style" do
      # CallNoArgNode |fork|
      #   VCallNode |fork|
      Given(:script) { "fork.fork" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(0) }
    end

    context "detects Kernel::fork style" do
      # CallNoArgNode |fork|
      #   ConstNode |Kernel|
      Given(:script) { "Kernel::fork" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end
  end

  context "Gem checker" do
    Given(:checker) { JRuby::Lint::Checkers::Gem.new }

    context "creates a finding for a gem mentioned in the libraries" do
      Given(:script) { "gem 'rdiscount'" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(2) }
    end

    context "creates one finding to mention the wiki for gem compatibility" do
      Given(:script) { "gem 'rdiscount'; gem 'bson_ext'" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(3) }
    end

    context "ignores platform for gem compatibility if not right platform" do
      Given(:script) { "gem 'rdiscount', platform: :ruby" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(0) }
    end

    context "creates a finding if platform for gem compatibility is ours" do
      Given(:script) { "gem 'rdiscount', platform: :jruby" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(2) }
    end


    context "does not create a finding for a gem not mentioned in the gems info" do
      Given(:script) { "gem 'json_pure'" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(0) }
    end

    context "only checks calls to #gem" do
      Given(:script) { "require 'rdiscount'" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(0) }
    end
  end

  context "Gemspec checker" do
    Given(:checker) { JRuby::Lint::Checkers::Gemspec.new }

    Given(:script) { "Gem::Specification.new do |s|" +
      "\ns.name = 'hello'\ns.add_dependency 'rdiscount'\n" +
      "s.add_development_dependency 'ruby-debug19'\nend\n" }

    When { collector.run }
    Then { expect(collector.findings.size).to eq(2) }
    Then { expect(collector.findings.detect{|f| f.message =~ /rdiscount/ }).to be_truthy }
  end

  context "Thread.critical checker" do
    Given(:checker) { JRuby::Lint::Checkers::ThreadCritical.new }

    context "read" do
      Given(:script) { "begin \n Thread.critical \n end"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "assign" do
      Given(:script) { "begin \n Thread.critical = true \n ensure Thread.critical = false \n end"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(2) }
    end
  end

  context "ObjectSpace" do
    Given(:checker) { JRuby::Lint::Checkers::ObjectSpace.new }

    context "_id2ref usage" do
      Given(:script) { "ObjectSpace._id2ref(obj)"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "each_object usage" do
      Given(:script) { "ObjectSpace.each_object { }"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "each_object(Class) usage is ok" do
      Given(:script) { "ObjectSpace.each_object(Class) { }"}
      When { collector.run }
      Then { collector.findings; expect(collector.findings.size).to eq(0) }
    end
  end

  context "System" do
    Given(:checker) { JRuby::Lint::Checkers::System.new }

    context "calling ruby -v in system" do
      Given(:script) { "system('echo'); system('/usr/bin/ruby -v')"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "calling ruby in the first argument to system" do
      Given(:script) { "system('/usr/bin/ruby', '-v')"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "calling irb or jirb from system" do
      Given(:script) { "system('jirb'); system('irb')"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(2) }
    end

    context "calling a .rb file from system" do
      Given(:script) { "system('asdf.rb')" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "calling ruby -v in Kernel.system should have a finding" do
      Given(:script) { "Kernel.system('ruby -v'); Kernel.system('echo \"zomg\"')"}
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

  end

  context "Non-atomic operator assignment" do
    Given(:checker) { JRuby::Lint::Checkers::NonAtomic.new }

    context "class variable or-assignment" do
      Given(:script) { "@@foo ||= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "instance variable or-assignment" do
      Given(:script) { "@foo ||= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "attribute or-assignment" do
      Given(:script) { "foo.bar ||= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "element or-assignment" do
      Given(:script) { "foo[bar] ||= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "class variable and-assignment" do
      Given(:script) { "@@foo &&= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "instance variable and-assignment" do
      Given(:script) { "@foo &&= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "attribute and-assignment" do
      Given(:script) { "foo.bar &&= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "element and-assignment" do
      Given(:script) { "foo[bar] &&= 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "class variable op-assignment" do
      Given(:script) { "@@foo += 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "instance variable op-assignment" do
      Given(:script) { "@foo += 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "attribute op-assignment" do
      Given(:script) { "foo.bar += 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end

    context "element op-assignment" do
      Given(:script) { "foo[bar] += 1" }
      When { collector.run }
      Then { expect(collector.findings.size).to eq(1) }
    end
  end
end
