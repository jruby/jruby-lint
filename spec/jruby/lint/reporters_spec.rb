require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Reporters do
  Given(:project) { double "project", :tags => %w(warning error info) }

  context "Text reporter" do
    Given(:reporter) { JRuby::Lint::Reporters::Text.new(project, output) }

    context "with a finding sharing a tag with the project" do
      Given(:finding) { double "finding", :to_s => "hello", :tags => %w(info) }
      Given(:output) { double("output").tap {|o| expect(o).to receive(:puts).with("hello") } }

      Then { reporter.report [finding] }
    end

    context "with a finding sharing no tags with the project" do
      Given(:finding) { double "finding", :to_s => "hello", :tags => %w(debug) }
      Given(:output) { double("output").tap {|o| expect(o).to_not receive(:puts) } }

      Then { reporter.report [finding] }
    end
  end

  context "Color text reporter" do
    include Term::ANSIColor
    Given(:reporter) { JRuby::Lint::Reporters::ANSIColor.new(project, output) }

    context "shows a finding tagged 'error' in red" do
      Given(:finding) { double "finding", :to_s => "hello", :tags => %w(error), :error? => true }
      Given(:output) { double("output").tap {|o| expect(o).to receive(:puts).with(red("hello")) } }

      Then { reporter.report [finding] }
    end

    context "shows a finding tagged 'warning' in cyan" do
      Given(:finding) { double "finding", :to_s => "hello", :tags => %w(warning), :error? => false, :warning? => true }
      Given(:output) { double("output").tap {|o| expect(o).to receive(:puts).with(cyan("hello")) } }

      Then { reporter.report [finding] }
    end
  end

  context "Html reporter" do
    Given(:reporter) { JRuby::Lint::Reporters::Html.new(project, 'lint-spec-report.html') }

    context "shows a finding tagged 'error' in red" do
      Given(:finding) { double "finding", :to_s => "hello", :tags => %w(error), :error? => true }
      Then { reporter.print_report [finding] }
      Then { expect(File.read('lint-spec-report.html')).to include('<li class="error">hello</li>') }
    end

    context "shows a finding tagged 'warning' in yellow" do
      Given(:finding) { double "finding", :to_s => "hello", :tags => %w(warning), :error? => false, :warning? => true }
      Then { reporter.print_report [finding] }
      Then { expect(File.read('lint-spec-report.html')).to include('<li class="warning">hello</li>') }
    end

    context "shows a nice message when we don't find any issue" do
      When { reporter.print_report [] }
      Then { expect(File.read('lint-spec-report.html')).to include('Congratulations!') }
    end
  end
end
