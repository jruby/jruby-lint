require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Collector do
  Given(:collector) { JRuby::Lint::Collector.new }
  Given(:checker_class) { Class.new { include JRuby::Lint::Checker } }

  it "loads detected checkers" do
    checker_class
    collector.checkers.detect {|c| checker_class === c }.should be_true
  end

  Given(:checker) { double("checker").tap {|checker| collector.checkers = [checker] } }

  it "invokes all checkers" do
    checker.should_receive(:check).with(collector)
    collector.run
  end
end

describe JRuby::Lint::FileCollector do
  Given { write_file('Hellofile', 'hi') }

  class HelloFileCollector
    include JRuby::Lint::FileCollector
    def check(collector)
      if contents =~ /hi/
        collector.findings << "File #{file} matches"
      end
    end
  end

  Given(:findings) { [] }
  Given(:collector) { double('collector', :findings => findings) }
  Given(:checker) { HelloFileCollector.new('Hellofile') }

  When { in_current_dir { checker.check(collector) } }
  Then { findings.should include("File Hellofile matches") }
end

describe JRuby::Lint::ASTCollector do
  class ScriptCollector
    include JRuby::Lint::ASTCollector
  end

  context "loads an AST" do
    Given(:checker) { ScriptCollector.new('puts "hello"') }

    When { @ast = checker.ast }
    Then { @ast.inspect.should =~ /"hello"/m }
  end
end
