require 'rspec'
require 'rspec/given'
require 'jruby/lint'
require 'aruba/api'

module JRuby::Lint::Specs
  PROJECT_DIR = File.expand_path('../..', __FILE__)
  def project_dir
    PROJECT_DIR
  end

  module NetAccess
    def requires_net_access
      require 'net/http'
      begin
        Net::HTTP.start('jruby.org', 80) {|x| x.head('/')}
        yield
      rescue
      end
    end
  end
end

RSpec.configure do |config|
  config.include JRuby::Lint::Specs
  config.include Aruba::Api
  config.extend JRuby::Lint::Specs::NetAccess

  config.before do
    @aruba_timeout_seconds = 20
    @existing_checkers = JRuby::Lint::Checker.loaded_checkers.dup
    in_current_dir { Dir['**/*'].each {|f| File.unlink(f) if File.file?(f) } }
  end

  config.after do
    JRuby::Lint::Checker.loaded_checkers.replace(@existing_checkers)
  end
end
