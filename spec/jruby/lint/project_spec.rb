require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Project do
  before { in_current_dir { Dir['**/*'].each {|f| File.unlink(f) if File.file?(f) } } }
  Given(:project) { in_current_dir { JRuby::Lint::Project.new } }

  context "collects Ruby scripts" do
    Given { write_file('script.rb', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
    Then { @collectors.first.should be_instance_of(JRuby::Lint::Collectors::Ruby) }
  end

  context "collects Bundler Gemfiles" do
    Given { write_file('Gemfile', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
    Then { @collectors.first.should be_instance_of(JRuby::Lint::Collectors::Bundler) }
  end

  context "collects Rakefiles" do
    Given { write_file('Rakefile', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
    Then { @collectors.first.should be_instance_of(JRuby::Lint::Collectors::Rake) }
  end

  context "collects gemspecs" do
    Given { write_file('temp.gemspec', '') }
    When { @collectors = project.collectors }
    Then { @collectors.size.should == 1 }
    Then { @collectors.first.should be_instance_of(JRuby::Lint::Collectors::Gemspec) }
  end

  context "aggregates findings from all collectors" do
    Given(:collector1) { double "collector 1" }
    Given(:collector2) { double "collector 2" }
    Given { collector1.should_receive(:run).ordered }
    Given { collector2.should_receive(:run).ordered }
    Given { collector1.should_receive(:findings).ordered.and_return [Object.new] }
    Given { collector2.should_receive(:findings).ordered.and_return [Object.new] }
    Given { project.collectors.replace([collector1, collector2]) }

    When { findings = project.run }
    Then { project.findings.size.should == 2 }
  end
end
