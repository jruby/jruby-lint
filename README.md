# JRuby-Lint

See how ready your Ruby code is to run on JRuby.

JRuby-Lint is a simple tool that allows you to check your project code
and configuration for common gotchas and issues that might make it
difficult to run your code on JRuby.

## Usage

JRuby-Lint requires JRuby to run. So, [install JRuby first][install]
if you already haven't, then `gem install jruby-lint`.

Then simply run `jrlint` in your project to receive a report of
places in your project where you should investigate further.

## Checks

Here is a list of the current checks implemented:

- Report usage of ObjectSpace.each_object and ObjectSpace._id2ref
  which are expensive and disabled by default
- Report usage of Thread.critical, which is discouraged in favor of a
  plain Mutex.
- Report known gems and libraries that use C extensions and try to
  provide known alternatives.
- Report usage of Kernel#fork (which does not work) and Kernel#exec
  (which does not replace the current process).
- Report usage of Timeout::timeout which, when used excessively tend
  to be slow and expensive because of native threads
- Report behavior difference when using system('ruby'), which launches
  the command in-process in a new copy of the interpreter for speed

## Reports

JRuby-lint supports text and html reports. Run jrlint with the option --html
to generate an html report with the results.

## TODO

Here is a list of checks and options we'd like to implement:

- Add in check for `` to make sure not execing ruby ...
- Report on more threading and concurrency issues/antipatterns
  - arr.each {|x| arr.delete(x) }
- Try to detect IO/File resource usage without blocks
- Check .gemspec files for extensions and extconf.rb for
  #create_makefile and warn about compiliing C extensions
- Check whether Rails production.rb contains `config.threadsafe!`
- Detect ERB files and skip them, or...
- Detect ERB files and pre-process them to Ruby source with Erubis
- Detect Bundler gems that have a `platforms` qualifier and ignore
  "platforms :ruby"
- Change to use jruby-parser
- 1.8/1.9 parser support/configuration without having to run JRuby
  itself in the right mode
- Allow use of a comment marker to suppress individual checks

### Further Down the Road

- Arbitrary method/AST search functionality 
- Code rewriter: option to change code automatically where it's
  feasible
- Revive or build an isit.jruby.org site for tracking
- Make JRuby-Lint submit results to tracking site based on lint passes
  and/or test suite runs

[install]: http://jruby.org/getting-started

## License

JRuby-Lint is Copyright (c) 2007-2013 The JRuby project, and is released
under a tri EPL/GPL/LGPL license. You can use it, redistribute it
and/or modify it under the terms of the:

  Eclipse Public License version 1.0
  GNU General Public License version 2
  GNU Lesser General Public License version 2.1

See the file `LICENSE.txt` in distribution for details.
