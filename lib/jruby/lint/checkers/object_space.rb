module JRuby::Lint
  module Checkers
    class ObjectSpace
      include Checker
      METHODS = [:each_object, :_id2ref]
      OK_ARGS = [:Class, :Module]

      def visitCallNode(node)
        if METHODS.include?(node.name)
          begin
            return unless node.receiver_node.node_type.to_s == "CONSTNODE" &&
                      node.receiver_node.name == :ObjectSpace
            return if node.args_node && node.args_node.size == 1 &&
                      OK_ARGS.include?(node.args_node.first.name)
            add_finding(collector, node)
          rescue
          end
        end
      end

      def add_finding(collector, node)
        collector.add_finding("Use of ObjectSpace is expensive and disabled by default. Use -X+O to enable.",
                                          [:objectspace, :warning], node.line+1)
      end
    end
  end
end
