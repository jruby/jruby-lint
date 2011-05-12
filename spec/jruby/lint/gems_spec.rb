require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::Gems do
  context "cache" do
    Given(:cache) { JRuby::Lint::Gems::Cache.new(current_dir) }

    context "fetch with net access", :requires_net => true do
      When { cache.fetch('C-Extension-Alternatives') }
      Then { check_file_presence('C-Extension-Alternatives.html', true) }
    end

    context "no net access" do
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
