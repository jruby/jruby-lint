# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jruby/lint/version"

Gem::Specification.new do |s|
  s.name        = "jruby-lint"
  s.version     = JRuby::Lint::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nick Sieger"]
  s.email       = ["nick@nicksieger.com"]
  s.licenses    = ["EPL 1.0", "GPL 2", "LGPL 2.1"]
  s.homepage    = "https://github.com/jruby/jruby-lint"
  s.summary     = %q{See how ready your Ruby code is to run on JRuby.}
  s.description = %q{This utility presents hints and suggestions to
  give you an idea of potentially troublesome spots in your code and
  dependencies that keep your code from running efficiently on JRuby.

  Most pure Ruby code will run fine, but the two common areas that
  trip people up are native extensions and threading}

  s.rubyforge_project = "jruby-lint"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "term-ansicolor"
  s.add_dependency "jruby-openssl"
  s.add_dependency "nokogiri", ">= 1.5.0.beta.4"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">= 2.5"
  s.add_development_dependency "rspec-given"
  s.add_development_dependency "aruba"
end

# Local Variables:
# mode: ruby
# End:
