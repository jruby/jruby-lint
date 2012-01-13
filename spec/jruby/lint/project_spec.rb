require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Project do
  Given(:project) { in_current_dir { JRuby::Lint::Project.new.tap {|p| p.reporters.clear } } }

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
    Given(:collector1) do
      double("collector 1").tap do |c1|
        c1.should_receive(:run)
        c1.stub!(:findings).and_return [double("finding 1")]
      end
    end
    Given(:collector2) do
      double("collector 2").tap do |c2|
        c2.should_receive(:run)
        c2.stub!(:findings).and_return [double("finding 2")]
      end
    end

    When { project.collectors.replace([collector1, collector2]) }
    When { findings = project.run }

    Then { project.findings.size.should == 2 }
  end

  context "reports findings" do
    Given(:finding) { double "finding" }

    Given(:collector) do
      double("collector").tap do |c|
        c.should_receive(:run)
        c.stub!(:findings).and_return [finding]
      end
    end

    Given(:reporter) do
      double("reporter").tap do |r|
        r.should_receive(:report).with([finding])
      end
    end

    When do
      reporter.stub!(:print_report)
      reporter.should_receive(:print_report).with([finding])
    end

    When do
      project.collectors.replace [collector]
      project.reporters.replace [reporter]
    end

    Then { project.run }
  end

  context 'initializing' do
    Given(:options) { OpenStruct.new }
    Given(:project) { in_current_dir { JRuby::Lint::Project.new(options) } }
    When { STDOUT.stub!(:tty?).and_return(false) }

    context 'tags' do
      Given(:options) { OpenStruct.new(:tags => ["debug"]) }
      Then { project.tags.should include("debug") }
      Then { project.tags.should include(*JRuby::Lint::Project::DEFAULT_TAGS) }
    end

    context 'reporters' do
      context 'with html option' do
        Given(:options) { OpenStruct.new(:html => 'report.html') }
        Then { project.reporters.should have(1).reporter }
        Then { project.reporters.first.should be_an_instance_of(JRuby::Lint::Reporters::Html) }
      end

      context 'with ansi option' do
        Given(:options) { OpenStruct.new(:ansi => true) }
        Then { project.reporters.should have(1).reporter }
        Then { project.reporters.first.should be_an_instance_of(JRuby::Lint::Reporters::ANSIColor) }
      end

      context 'with text option' do
        Given(:options) { OpenStruct.new(:text => true) }
        Then { project.reporters.should have(1).reporter }
        Then { project.reporters.first.should be_an_instance_of(JRuby::Lint::Reporters::Text) }
      end

      context 'with tty' do
        Given { STDOUT.stub(:tty?).and_return(true) }
        Then { project.reporters.should have(1).reporter }
        Then { project.reporters.first.should be_an_instance_of(JRuby::Lint::Reporters::ANSIColor) }
      end

      context 'without any option' do
        Then { project.reporters.should have(1).reporter }
        Then { project.reporters.first.should be_an_instance_of(JRuby::Lint::Reporters::Text) }
      end

      context 'with several options' do
        Given(:options) { OpenStruct.new(:ansi => true, :html => 'report.html') }
        Then { project.reporters.should have(2).reporter }
        Then { project.reporters.map(&:class).should include(JRuby::Lint::Reporters::ANSIColor) }
        Then { project.reporters.map(&:class).should include(JRuby::Lint::Reporters::Html) }
      end
    end
  end
end
