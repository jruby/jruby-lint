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

## TODO

Here is a list of checks and options we'd like to implement:

- Options to save report off to a file.
  - Text, HTML formats
- Report on threading and concurrency issues
- Warn about `system("ruby ...")` and the like
- Try to detect IO/File resource usage without blocks
- Detect ERB files and skip them, or...
- Detect ERB files and pre-process them to Ruby source with Erubis
- Detect Bundler gems that have a `platforms` qualifier and ignore
  "platforms :ruby"
- 1.8/1.9 parser support/configuration without having to run JRuby
  itself in the right mode

### Further Down the Road

- Arbitrary method/AST search functionality 
- Code rewriter: option to change code automatically where it's
  feasible
- Revive or build an isit.jruby.org site for tracking
- Make JRuby-Lint submit results to tracking site based on lint passes
  and/or test suite runs

[install]: http://jruby.org/getting-started
