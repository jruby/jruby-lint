require 'bundler'
Bundler::GemHelper.install_tasks

require 'bundler/setup'
require 'rspec/core/rake_task'
ENV['RUN_ALL_SPECS'] = 'true'   # Always run all specs from Rake
RSpec::Core::RakeTask.new

task :default => [:update_fixtures, :spec]

require 'rake/clean'
require 'open-uri'
require 'net/https'

file "spec/fixtures/C-Extension-Alternatives.html" do |t|
  require 'jruby/lint/libraries'
  cache = JRuby::Lint::Libraries::Cache.new('spec/fixtures')
  cache.fetch("C-Extension-Alternatives")
end

fixtures = ["spec/fixtures/C-Extension-Alternatives.html"]
task :update_fixtures => fixtures

CLOBBER.push *fixtures
