JRuby does not support native C extensions, but it does have it's own Java native extensions API.  Several gems have implementations of both Java and C extensions rolled into the same gem and those will not be listed here since they will just work.  In some cases there is a JRuby version with a slightly different name or possibly even a totally different name and we list these here so you can update your Gemfile:

```ruby
gem 'therubyracer', platform: :mri
gem 'therubyrhino', platform: :jruby
```

When there is not an exact match some gems come close enough where a little work on your part can make your application compatible with JRuby.

This page lists common C extensions and JRuby-friendly alternatives you can use to replace them.

If you are interested in helping us port an extension to JRuby, this article is helpful: [Your first Ruby native extension: Java](https://blog.jcoglan.com/2012/08/02/your-first-ruby-native-extension-java/) see also [JRuby examples](https://github.com/jruby/jruby-examples) for a maven build.

<!-- suggestions start -->
| Gem | Suggestions |
|-----|-------------|
|[RDiscount][]|Use [kramdown][], [Maruku][] (pure Ruby) or [markdown_j][] (wrapper around a Java library)|
|[RedCarpet][]|Same as with **RDiscount** use alternatives such as [kramdown][], [Maruku][] or [markdown_j][]|
|[RMagick][]|Try [RMagick4J][] (implements ImageMagick functionality in Java) or preferably use alternatives [mini_magick][] & [quick_magick][]. For simple resizing, cropping, greyscaling, etc look at [image_voodoo][]. You can also use Java's Graphics2D.|
|[Unicorn][]| Use [Puma][].|
|[Thin][]| Use [Puma][].|
|mysql|Use [activerecord-jdbcmysql-adapter][].|
|mysql2|Use [activerecord-jdbcmysql-adapter][].|
|sqlite3|Use [activerecord-jdbcsqlite3-adapter][].|
|pg|Use [activerecord-jdbcpostgresql-adapter][] instead or [pg_jruby][] (drop-in replacement).|
|[yajl-ruby][]|Try `json` or `json_pure` instead. Unfortunately there is no known equivalent JSON stream parser.|
|[oj][]|Try `gson`, `json` or `json_pure` instead.|
|[bson_ext][]|`bson_ext` isn't used with JRuby. Instead, some native Java extensions are bundled with the `bson` gem.|
|[win32ole][]|Use the `jruby-win32ole` gem (preinstalled in JRuby's Windows installer).|
|[curb][]|[Rurl][] is an example how to implement _some_ of curb's functionality using [Apache HttpClient][]|
|[therubyracer][]|Try using [therubyrhino][] instead (or [dienashorner][] on Java 8+).|
|[kyotocabinet][]|Try using [kyotocabinet-java][] instead. This isn't 100% complete yet, but it covers most of the API.|
|[memcached][]|Try using [jruby-memcached][] instead. Alternatively you can use [jruby-ehcache][], a JRuby interface to Java's (JSR-107 compliant) Ehcache.|
<!-- suggestions end -->

Please add to this list with your findings.

*Note that the [JRuby-Lint][] gem parses the contents of the list above to use for its Ruby gem checker. In order for JRuby-Lint to use the information, please adhere to the table format above and the links to projects below (in the source for this page).

<!-- links start -->
[RDiscount]: http://dafoster.net/projects/rdiscount/
[RedCarpet]: https://github.com/vmg/redcarpet
[kramdown]: https://github.com/gettalong/kramdown
[Maruku]:https://github.com/bhollis/maruku
[markdown_j]: https://github.com/nate/markdown_j
[RMagick]: https://github.com/rmagick/rmagick
[RMagick4J]: https://github.com/Serabe/RMagick4J
[mini_magick]: https://github.com/minimagick/minimagick
[quick_magick]: https://github.com/aseldawy/quick_magick
[image_voodoo]: https://github.com/jruby/image_voodoo
[Unicorn]: http://unicorn.bogomips.org/
[Puma]: http://puma.io/
[Thin]: http://code.macournoyer.com/thin/
[Typhoeus]: https://github.com/dbalatero/typhoeus
[activerecord-jdbc-adapter]: https://github.com/jruby/activerecord-jdbc-adapter
[JRuby-Lint]: https://github.com/jruby/jruby-lint
[Nokogiri]: http://nokogiri.org/
[yajl-ruby]: https://github.com/brianmario/yajl-ruby
[bson_ext]: https://github.com/mongodb/mongo-ruby-driver
[Apache HttpClient]: http://hc.apache.org/httpcomponents-client-ga/
[HttpURLConnection]: http://download.oracle.com/javase/1,5.0/docs/api/java/net/HttpURLConnection.html
[win32ole]: http://www.ruby-doc.org/stdlib/libdoc/win32ole/rdoc/index.html
[Rurl]: https://github.com/rcyrus/Rurl
[curb]: https://github.com/taf2/curb
[therubyracer]: https://github.com/cowboyd/therubyracer
[therubyrhino]: https://github.com/cowboyd/therubyrhino
[dienashorner]: https://github.com/kares/dienashorner
[kyotocabinet]: http://fallabs.com/kyotocabinet/
[kyotocabinet-java]: https://github.com/csw/kyotocabinet-java
[memcached]: https://github.com/evan/memcached
[jruby-memcached]: https://github.com/aurorafeint/jruby-memcached
[jruby-ehcache]: https://github.com/dylanz/ehcache
[oj]: https://github.com/ohler55/oj
[activerecord-jdbcmysql-adapter]: https://rubygems.org/gems/activerecord-jdbcmysql-adapter
[activerecord-jdbcsqlite3-adapter]: https://rubygems.org/gems/activerecord-jdbcsqlite3-adapter
[activerecord-jdbcpostgresql-adapter]: https://rubygems.org/gems/activerecord-jdbcpostgresql-adapter
[pg_jruby]: https://rubygems.org/gems/pg_jruby
<!-- links start -->