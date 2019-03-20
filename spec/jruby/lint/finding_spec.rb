require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Finding do
  Given(:message) { "bad code" }
  Given(:file) { "file" }
  Given(:line) { 19 }
  Given(:tags) { ["threads", "info"] }

  context "has a message, location and tags" do
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { expect(@finding.message).to eq(message) }
    Then { expect(@finding.tags).to eq(tags) }
    Then { expect(@finding.file).to eq(file) }
    Then { expect(@finding.line).to eq(line) }
    Then { expect(@finding.to_s).to eq("#{file}:#{line}: [#{tags.join(', ')}] #{message}") }
  end

  context "can receive location from SourcePosition" do
    Given(:source_position) { org.jruby.lexer.yacc.SimpleSourcePosition.new(file, line) }

    When { @finding = JRuby::Lint::Finding.new(message, tags, source_position) }
    Then { expect(@finding.file).to eq(file) }
    Then { expect(@finding.line).to eq(line + 1) }
  end

  context "converts all tags to strings" do
    Given(:tags) { [1, :two, 3.0] }
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { expect(@finding.tags).to eq(["1", "two", "3.0"]) }
  end

  context "with error tags" do
    Given(:tags) { [:error] }
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { expect(@finding).to be_error }
  end

  context "with warnings tags" do
    Given(:tags) { [:warning] }
    When { @finding = JRuby::Lint::Finding.new(message, tags, file, line) }
    Then { expect(@finding).to be_warning }
  end
end
