require 'net/https'
require 'tempfile'
require 'fileutils'

module JRuby::Lint
  class Libraries
    class Cache
      def initialize(cache_dir = nil)
        @cache_dir = cache_dir || ENV['JRUBY_LINT_CACHE'] ||
          (defined?(Gem.user_dir) && File.join(Gem.user_dir, 'lint')) || Dir::tmpdir
        FileUtils.mkdir_p(@cache_dir) unless File.directory?(@cache_dir)
      end

      def fetch(name)
        filename = filename_for(name)
        if File.file?(filename) && !stale?(filename)
          File.read(filename)
        else
          read_from_wiki(name, filename)
        end
      end

      def store(name, content)
        File.open(filename_for(name), "w") {|f| f << content }
      end

      def filename_for(name)
        name = File.basename(name)
        File.join(@cache_dir, File.extname(name).empty? ? "#{name}.md" : name)
      end

      def stale?(filename)
        File.mtime(filename) < Time.now - 24 * 60 * 60
      end

      def read_from_wiki(name, filename)
        require 'open-uri'
        download = open('https://github.com/jruby/jruby/wiki/C-Extension-Alternatives.md')
        content = download.read(nil)
        File.open(filename, "w") { |f| f << content }
        content
      rescue => e
        raise "Error while reading from wiki: #{e.message}\nPlease try again later."
      end
    end

    class CExtensions
      attr_reader :gems

      def initialize(cache)
        @cache = cache
      end

      def load
        @gems = {}
        content = @cache.fetch('C-Extension-Alternatives.md')

        in_suggestions = false
        content.split("\n").each do |line|
          if line =~ /<!-- suggestions start/
            in_suggestions = true
          elsif !in_suggestions
            next
          elsif line =~ /<!-- suggestions end/
            in_suggestions = false
            break
          else
            _, key, value = line.gsub(/[\[\]]/, '').split("|", 3)
            @gems[key.downcase] = value
          end
        end
      rescue => e
        @error = "Unable to load C Extension alternatives list: #{e.message}"
      end
    end

    SOURCES = [CExtensions]

    attr_accessor :gems

    def initialize(cache)
      @sources = SOURCES.map {|s| s.new(cache) }
    end

    def load
      @gems = {}.tap do |gems|
        @sources.each do |s|
          s.load
          gems.update(s.gems)
        end
      end
    end

    def gems
      @gems ||= load
    end
  end
end
