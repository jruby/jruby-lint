require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Checker do
  context "checkers" do
    subject { Class.new { include JRuby::Lint::Checker } }

    it "finds all loaded checkers" do
      JRuby::Lint::Checker.loaded_checkers.should include(subject)
    end
  end
end

describe JRuby::Lint::FileChecker do
  Given { write_file('Hellofile', 'hi') }

  class HelloFileChecker
    include JRuby::Lint::FileChecker
    def check(collector)
      if contents =~ /hi/
        collector.findings << "File #{file} matches"
      end
    end
  end

  Given(:checker) { HelloFileChecker.new('Hellofile') }
  Given(:findings) { [] }
  Given(:collector) { double('collector', :findings => findings) }
  When { in_current_dir { checker.check(collector) } }
  Then { findings.should include("File Hellofile matches") }
end
