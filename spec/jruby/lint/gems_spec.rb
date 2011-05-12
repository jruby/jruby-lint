require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Gems do
  context "cache" do
    Given(:cache) { JRuby::Lint::Gems::Cache.new(current_dir) }

    context "with net access", :requires_net => true do
      context "fetch" do
        When { cache.fetch('C-Extension-Alternatives') }
        Then { check_file_presence('C-Extension-Alternatives.html', true) }
      end

      context "refreshes a file that's too old" do
        Given { write_file('C-Extension-Alternatives.html', 'alternatives') }
        Given(:yesterday) { Time.now - 25 * 60 * 60 }
        Given { File.utime yesterday, yesterday, File.join(current_dir, 'C-Extension-Alternatives.html')}
        When { cache.fetch('C-Extension-Alternatives') }
        Then { File.mtime(File.join(current_dir, 'C-Extension-Alternatives.html')).should > yesterday }
      end
    end

    context "with no net access" do
      Given { Net::HTTP.should_not_receive(:start) }

      context "store assumes .html extension by default" do
        When { cache.store('hello.yml', 'hi')}
        Then { check_file_presence('hello.yml', true) }
      end

      context "store assumes .html extension by default" do
        When { cache.store('hello', 'hi')}
        Then { check_file_presence('hello.html', true) }
      end

      context "fetch should not access net when file is cached" do
        Given { write_file('hello.html', 'hi') }
        When { cache.fetch('hello') }
      end
    end
  end

  context "c extensions list" do
    Given(:cache) { JRuby::Lint::Gems::Cache.new(File.expand_path('../../../fixtures', __FILE__))}
    Given(:list) { JRuby::Lint::Gems::CExtensions.new(cache) }
    When { list.load }
    Then { list.gems.keys.should include("rdiscount", "rmagick")}
  end
end
