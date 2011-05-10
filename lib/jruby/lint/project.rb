module JRuby::Lint
  class Project
    attr_reader :collectors, :findings

    def initialize
      @collectors = load_collectors
    end

    def run
      collectors.each {|c| c.run }
      @findings = []
      collectors.each {|c| @findings += c.findings }
    end

    private
    def load_collectors
      [].tap do |collectors|
        Dir['**/*'].each do |f|
          next unless File.file?(f)
          Collector.all.each do |c|
            collectors << c.new(f) if c.detect?(f)
          end
        end
      end
    end
  end
end
