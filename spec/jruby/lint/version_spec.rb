require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint, "version" do
  Given(:version) { JRuby::Lint::VERSION }
  Then { expect(version).to be >= "0" }
end
