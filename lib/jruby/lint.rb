begin
  require 'jruby'
rescue LoadError
  raise LoadError, 'JRuby-Lint must be run under JRuby'
end

module JRuby
  module Lint
  end
end

require 'jruby/lint/collector'
require 'jruby/lint/checkers'
require 'jruby/lint/ast'
require 'jruby/lint/version'
