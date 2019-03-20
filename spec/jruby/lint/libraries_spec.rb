require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Libraries do
  Given(:cache_dir) { ENV['JRUBY_LINT_CACHE'] }
  Given(:cache) { JRuby::Lint::Libraries::Cache.new(cache_dir) }

  context "cache" do
    Given(:cache_dir) { expand_path(".") }

    context "with net access", :requires_net => true do
      context "fetch" do
        When { cache.fetch('C-Extension-Alternatives') }
        Then { expect('C-Extension-Alternatives.md').to be_an_existing_file }
      end

      context "refreshes a file that's too old" do
        Given { write_file('C-Extension-Alternatives.md', 'alternatives') }
        Given(:yesterday) { Time.now - 25 * 60 * 60 }
        Given { File.utime yesterday, yesterday, File.join(expand_path("."), 'C-Extension-Alternatives.md')}
        When { cache.fetch('C-Extension-Alternatives') }
        Then { expect(File.mtime(File.join(expand_path("."), 'C-Extension-Alternatives.md'))).to be > yesterday }
      end
    end

    context "with no net access" do
      Given { expect(Net::HTTP).not_to receive(:start) }

      context "store assumes .md extension by default" do
        When { cache.store('hello.yml', 'hi')}
        Then { expect('hello.yml').to be_an_existing_file }
      end

      context "store assumes .md extension by default" do
        When { cache.store('hello', 'hi')}
        Then { expect('hello.md').to be_an_existing_file }
      end

      context "fetch should not access net when file is cached" do
        Given { write_file('hello.md', 'hi') }
        When { cache.fetch('hello') }
      end
    end
  end

  context "c extensions list" do
    Given(:list) { JRuby::Lint::Libraries::CExtensions.new(cache) }
    When { list.load }
    Then { expect(list.gems.keys).to include("rdiscount", "rmagick")}
  end

  context "aggregate information" do
    Given(:info) { JRuby::Lint::Libraries.new(cache) }
    When { info.load }
    Then { expect(info.gems.keys).to include("rdiscount", "rmagick")}
  end
end
