require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Project do
  Given(:project) { cd('.') { JRuby::Lint::Project.new.tap {|p| p.reporters.clear } } }

  context "collects Ruby scripts" do
    Given { write_file('script.rb', '') }
    When { @collectors = project.collectors }
    Then { expect(@collectors.size).to eq(1) }
    Then { expect(@collectors.first).to be_instance_of(JRuby::Lint::Collectors::Ruby) }
  end

  context "collects Bundler Gemfiles" do
    Given { write_file('Gemfile', '') }
    When { @collectors = project.collectors }
    Then { expect(@collectors.size).to eq(1) }
    Then { expect(@collectors.first).to be_instance_of(JRuby::Lint::Collectors::Bundler) }
  end

  context "collects Rakefiles" do
    Given { write_file('Rakefile', '') }
    When { @collectors = project.collectors }
    Then { expect(@collectors.size).to eq(1) }
    Then { expect(@collectors.first).to be_instance_of(JRuby::Lint::Collectors::Rake) }
  end

  context "collects gemspecs" do
    Given { write_file('temp.gemspec', '') }
    When { @collectors = project.collectors }
    Then { expect(@collectors.size).to eq(1) }
    Then { expect(@collectors.first).to be_instance_of(JRuby::Lint::Collectors::Gemspec) }
  end

  context "aggregates findings from all collectors" do
    Given(:collector1) do
      double("collector 1").tap do |c1|
        expect(c1).to receive(:run)
        allow(c1).to receive(:findings) { [double("finding 1")] }
      end
    end
    Given(:collector2) do
      double("collector 2").tap do |c2|
        expect(c2).to receive(:run)
        allow(c2).to receive(:findings) { [double("finding 2")] }
      end
    end

    When { project.collectors.replace([collector1, collector2]) }
    When { findings = project.run }

    Then { expect(project.findings.size).to eq(2) }
  end

  context "reports findings" do
    Given(:finding) { double "finding" }

    Given(:collector) do
      double("collector").tap do |c|
        expect(c).to receive(:run)
        allow(c).to receive(:findings) { [finding] }
      end
    end

    Given(:reporter) do
      double("reporter").tap do |r|
        expect(r).to receive(:report).with([finding])
      end
    end

    When do
      allow(reporter).to receive(:print_report)
      expect(reporter).to receive(:print_report).with([finding])
    end

    When do
      project.collectors.replace [collector]
      project.reporters.replace [reporter]
    end

    Then { project.run }
  end

  context 'initializing' do
    Given(:options) { OpenStruct.new }
    Given(:project) { cd('.') { JRuby::Lint::Project.new(options) } }
    When { allow(STDOUT).to receive(:tty?).and_return(false) }

    context 'tags' do
      Given(:options) { OpenStruct.new(:tags => ["debug"]) }
      Then { expect(project.tags).to include("debug") }
      Then { expect(project.tags).to include(*JRuby::Lint::Project::DEFAULT_TAGS) }
    end

    context 'reporters' do
      context 'with html option' do
        Given(:options) { OpenStruct.new(:html => 'report.html') }
        Then { expect(project.reporters.size).to equal(1) }
        Then { expect(project.reporters.first).to be_an_instance_of(JRuby::Lint::Reporters::Html) }
      end

      context 'with ansi option' do
        Given(:options) { OpenStruct.new(:ansi => true) }
        Then { expect(project.reporters.size).to equal(1) }
        Then { expect(project.reporters.first).to be_an_instance_of(JRuby::Lint::Reporters::ANSIColor) }
      end

      context 'with text option' do
        Given(:options) { OpenStruct.new(:text => true) }
        Then { expect(project.reporters.size).to equal(1) }
        Then { expect(project.reporters.first).to be_an_instance_of(JRuby::Lint::Reporters::Text) }
      end

      context 'without any option' do
        Then { expect(project.reporters.size).to equal(1) }
        Then { expect(project.reporters.first).to be_an_instance_of(JRuby::Lint::Reporters::Text) }
      end

      context 'with several options' do
        Given(:options) { OpenStruct.new(:ansi => true, :html => 'report.html') }
        Then { expect(project.reporters.size).to eq(2) }
        Then { expect(project.reporters.map(&:class)).to include(JRuby::Lint::Reporters::ANSIColor) }
        Then { expect(project.reporters.map(&:class)).to include(JRuby::Lint::Reporters::Html) }
      end
    end
  end
end
