require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Project do
  before { in_current_dir { Dir['**/*'].each {|f| File.unlink(f) if File.file?(f) } } }
  Given(:project) { in_current_dir { JRuby::Lint::Project.new } }

  context "collects Ruby scripts" do
    Given { write_file('script.rb', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
  end

  context "collects Bundler Gemfiles" do
    Given { write_file('Gemfile', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
  end

  context "collects Rakefiles" do
    Given { write_file('Rakefile', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
  end

  context "collects gemspecs" do
    Given { write_file('temp.gemspec', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
  end
end
