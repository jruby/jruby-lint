module JRuby::Lint
  module Checkers
    class ObjectSpace
      include Checker
      METHODS = %w(each_object _id2ref)

      def visitCallNode(node)
        if METHODS.include?(node.name)
          begin
            if node.receiver_node.node_type.to_s == "CONSTNODE" && node.receiver_node.name == "ObjectSpace" then
              if node.args_node && node.args_node.size == 1 &&
                %w(Class Module).include?(node.args_node[0].name) then
                add_finding(collector, node)
              end
            end
          rescue
          end
        end
      end

      def add_finding(collector, node)
        collector.findings << Finding.new("Use of ObjectSpace is expensive and disabled by default. Use -X+O to enable.",
                                          [:objectspace, :warning], node.position)
      end
    end
  end
end
