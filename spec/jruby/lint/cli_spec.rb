require File.expand_path('../../../spec_helper', __FILE__)
require 'jruby/lint/cli'

describe JRuby::Lint::CLI do
  context "with the tag option" do
    Given(:cli) { JRuby::Lint::CLI.new(args) }
    Given(:args) { ["--tag", "debug"]}
    When { cli }
    Then { cli.options.tags.should include("debug") }
  end

  context "when launched" do
    Given(:command) { "ruby -I#{project_dir}/lib -S #{project_dir}/bin/jrlint #{args}" }

    context "with the help option" do
      Given(:args) { "--help" }
      When { run_simple(command) }
      Then do
        output_from(command).should =~ /help.*This message/
        @last_exit_status.should == 0
      end
    end

    context "with the version option" do
      Given(:args) { "--version" }
      When { run_simple(command) }
      Then do
        output_from(command).should =~ /version #{JRuby::Lint::VERSION}/
        @last_exit_status.should == 0
      end
    end

    context "with a dash-e option" do
      Given(:args) { "-e true"}
      When { run_simple(command) }
      Then do
        output_from(command).should =~ /Processed 1 expression/
        @last_exit_status.should == 0
      end
    end

    context "with a file argument" do
      Given(:args) { "sample.rb" }
      Given { write_file("sample.rb", "puts 'hello'"); write_file("example.rb", "puts 'hello'") }
      When { run_simple(command) }
      Then do
        output_from(command).should =~ /Processed 1 file/
        @last_exit_status.should == 0
      end
    end

    context "with no arguments" do
      Given(:args) { "" }

      context "and some files to process" do
        Given { write_file("Rakefile", "") }
        When { run_simple(command) }
        Then do
          output = output_from(command)
          output.should =~ /JRuby-Lint version #{JRuby::Lint::VERSION}/
          output.should =~ /Processed 1 file/
          output.should =~ /OK/
          @last_exit_status.should == 0
        end
      end

      context "and no files to process" do
        When { run_simple(command) }
        Then { output_from(command).should =~ /Processed 0 files/ }
      end
    end
  end
end
