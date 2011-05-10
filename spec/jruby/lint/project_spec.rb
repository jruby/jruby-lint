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
    Given(:collector1) do
      double("collector 1").tap do |c1|
        c1.should_receive(:run)
        c1.should_receive(:findings).and_return [double "finding 1"]
      end
    end
    Given(:collector2) do
      double("collector 2").tap do |c2|
        c2.should_receive(:run)
        c2.should_receive(:findings).and_return [double "finding 2"]
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
        c.should_receive(:findings).and_return [finding]
      end
    end

    Given(:reporter) do
      double("reporter").tap do |r|
        r.should_receive(:report).with([finding])
      end
    end

    When do
      project.collectors.replace [collector]
      project.reporters.replace [reporter]
    end

    Then { project.run }
  end
end
