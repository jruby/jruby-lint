module JRuby::Lint
  module Checkers
    class ThreadCritical
      include Checker

      METHODS = %w(critical critical=)

      def visitCallNode(node)
        if METHODS.include?(node.name)
          begin
            if node.receiver_node.node_type.to_s == "CONSTNODE" && node.receiver_node.name == "Thread"
              add_finding(collector, node)
            end
          rescue
          end
        end
      end
      alias visitAttrAssignNode visitCallNode

      def add_finding(collector, node)
        collector.findings << Finding.new("Use of Thread.critical is discouraged. Use a Mutex instead.",
                                          [:threads, :warning], node.position)
      end
    end
  end
end
