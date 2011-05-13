require 'rspec'
require 'rspec/given'
require 'jruby/lint'
require 'aruba/api'

module JRuby::Lint::Specs
  PROJECT_DIR = File.expand_path('../..', __FILE__)
  def project_dir
    PROJECT_DIR
  end
  ENV['JRUBY_LINT_CACHE'] = "#{PROJECT_DIR}/spec/fixtures"
end

RSpec.configure do |config|
  config.include JRuby::Lint::Specs
  config.include Aruba::Api

  config.filter_run_excluding :requires_net => true unless ENV['RUN_ALL_SPECS']

  config.before do
    @aruba_timeout_seconds = 20
    @existing_checkers = JRuby::Lint::Checker.loaded_checkers.dup
    in_current_dir { Dir['**/*'].each {|f| File.unlink(f) if File.file?(f) } }
    JRuby::Lint::Checkers::CheckGemNode.instance_eval { @added_wiki_link = nil }
  end

  config.after do
    JRuby::Lint::Checker.loaded_checkers.replace(@existing_checkers)
  end
end
