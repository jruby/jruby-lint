require File.expand_path('../../../spec_helper', __FILE__)
require 'jruby/lint/cli'

describe JRuby::Lint::CLI do
  context "when launched" do
    Given(:command) { "ruby -I#{project_dir}/lib -S #{project_dir}/bin/jrlint #{args}" }

    context "with the help option" do
      Given(:args) { "--help" }
      When { run_simple(command) }
      Then { output_from(command).should =~ /help.*This message/ }
      Then { @last_exit_status.should == 0 }
    end

    context "with the version option" do
      Given(:args) { "--version" }
      When { run_simple(command) }
      Then { output_from(command).should =~ /version #{JRuby::Lint::VERSION}/ }
      Then { @last_exit_status.should == 0 }
    end
  end
end
