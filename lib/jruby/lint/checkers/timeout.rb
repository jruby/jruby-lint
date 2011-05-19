module JRuby::Lint
  module Checkers
    class Timeout
      include Checker

      def visitCallNode(node)
        if node.name == "timeout"
          begin
            add_finding(collector, node)
          rescue
          end
        end
      end

      def add_finding(collector, node)
        collector.findings << Finding.new("Timeout in JRuby does not work in many cases",
                                          [:timeout, :warning], node.position)
      end
    end
  end
end