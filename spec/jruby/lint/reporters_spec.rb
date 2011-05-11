require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Reporters::Text do
  Given(:project) { double "project", :tags => %w(warning error info) }
  Given(:reporter) { JRuby::Lint::Reporters::Text.new(project, output) }

  context "with a finding sharing a tag with the project" do
    Given(:finding) { double "finding", :to_s => "hello", :tags => %w(info) }
    Given(:output) { double("output").tap {|o| o.should_receive(:puts).with("hello") } }

    Then { reporter.report [finding] }
  end

  context "with a finding sharing no tags with the project" do
    Given(:finding) { double "finding", :to_s => "hello", :tags => %w(debug) }
    Given(:output) { double("output").tap {|o| o.should_not_receive(:puts) } }

    Then { reporter.report [finding] }
  end
end
