require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Finding do
  Given(:message) { "bad code" }
  Given(:file) { "file" }
  Given(:line) { 19 }
  Given(:tags) { ["threads", "info"] }

  context "has a message, location and tags" do
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { @finding.message.should == message }
    Then { @finding.tags.should == tags }
    Then { @finding.file.should == file }
    Then { @finding.line.should == line }
    Then { @finding.to_s.should == "#{file}:#{line}: [#{tags.join(', ')}] #{message}" }
  end

  context "can receive location from SourcePosition" do
    Given(:source_position) { org.jruby.lexer.yacc.SimpleSourcePosition.new(file, line) }

    When { @finding = JRuby::Lint::Finding.new(message, tags, source_position) }
    Then { @finding.file.should == file }
    Then { @finding.line.should == line + 1 }
  end

  context "converts all tags to strings" do
    Given(:tags) { [1, :two, 3.0] }
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { @finding.tags.should == ["1", "two", "3.0"] }
  end

  context "with error tags" do
    Given(:tags) { [:error] }
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { @finding.should be_error }
  end

  context "with warnings tags" do
    Given(:tags) { [:warning] }
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { @finding.should be_warning }
  end
end
