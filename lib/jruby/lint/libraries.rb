require 'net/https'
require 'nokogiri'
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
        File.join(@cache_dir, File.extname(name).empty? ? "#{name}.html" : name)
      end

      def stale?(filename)
        File.mtime(filename) < Time.now - 24 * 60 * 60
      end

      def read_from_wiki(name, filename)
        content = nil
        uri = Net::HTTP.start('wiki.jruby.org', 80) do |http|
          URI.parse http.head(name =~ %r{^/} ? name : "/#{name}")['Location']
        end
        if uri.host == "github.com"
          Net::HTTP.new(uri.host, uri.port).tap do |http|
            if uri.scheme == "https"
              http.use_ssl = true
              http.verify_mode = OpenSSL::SSL::VERIFY_PEER
              # gd_bundle.crt from https://certs.godaddy.com/anonymous/repository.seam
              http.ca_file = File.expand_path('../github.crt', __FILE__)
            end
            http.start do
              response = http.get(uri.path)
              content = response.body
              File.open(filename, "w") do |f|
                f << content
              end
            end
          end
        end
        raise "Unknown location '#{uri}' for page '#{name}'" unless content
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
        content = @cache.fetch('C-Extension-Alternatives')
        doc = Nokogiri::HTML(content)
        doc.css('#wiki-body ul li').each do |li|
          key, message = li.text.split(/[ -]+/, 2)
          @gems[key.downcase] = message
        end
      rescue => e
        @error = "Unable to load C Extension alternatives list: #{e.message}"
      end
    end

    SOURCES = [CExtensions]

    attr_reader :gems

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
