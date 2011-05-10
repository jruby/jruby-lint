require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Reporters::Text do
  Given(:finding) { double "finding", :to_s => "hello" }
  Given(:output) { double("output").tap {|o| o.should_receive(:puts).with("hello") } }
  Given(:reporter) { JRuby::Lint::Reporters::Text.new(output) }

  Then { reporter.report [finding] }
end
