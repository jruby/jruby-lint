require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint do
  Given(:version) { JRuby::Lint::VERSION }
  Then { version.should >= "0" }
end
