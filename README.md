# JRuby-Lint

See how ready your Ruby code is to run on JRuby.

JRuby-Lint is a simple tool that allows you to check your project code
and configuration for common gotchas and issues that might make it
difficult to run your code on JRuby.

## Usage

JRuby-Lint requires JRuby to run. So, [install JRuby first][install]
if you already haven't.

Then simply run `jrlint` in your project to receive a report of
places in your project where you should investigate further.

## TODO

At this point, everything, but here is a list of things we'd like to
implement:

- Options to save report off to a file.
  - Text, HTML formats
- Report on gem compatibility from gems found in `*.gemspec` and
  `Gemfile`.
  - Compile a gem compatibility list from the JRuby wiki, with an
    offline cache released with each gem.
- Report on threading and concurrency issues
- Report usage of `#fork` and `#exec`
- Warnings vs. errors -- lint levels
- Warn about `system("ruby ...")` and the like
- Warn about `ObjectSpace.each_object(...)`
- Warn about `ObjectSpace.id2ref` etc
- Warn about `Thread.critical`, `Thread#kill` and the like
- Try to detect IO/File resource usage without blocks

### Further Down the Road

- Code rewriter: option to change code automatically where it's
  feasible
- Revive or build an isit.jruby.org site for tracking
- Make JRuby-Lint submit results to tracking site based on lint passes
  and/or test suite runs

[install]: http://jruby.org/getting-started
