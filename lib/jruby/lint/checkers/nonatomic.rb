module JRuby::Lint
  module Checkers
    class NonAtomic
      include Checker

      def visitOpAsgnOrNode(node)
        check_nonatomic(node, node.first_node)
      end

      def visitOpAsgnAndNode(node)
        check_nonatomic(node, node.first_node)
      end

      def visitOpElementAsgnNode(node)
        add_finding(collector, node)
      end

      def visitOpAsgnNode(node)
        check_nonatomic(node, node.receiver_node)
      end

      def check_nonatomic(orig_node, risk_node)
        case risk_node
        when org::jruby::ast::LocalVarNode,
             org::jruby::ast::DVarNode
          # ok...mostly-safe cases
        else
          add_finding(collector, orig_node)
        end
      end

      def add_finding(collector, node)
        collector.findings << Finding.new("Non-local operator assignment is not guaranteed to be atomic",
                                          [:nonatomic, :warning], node.position)
      end
    end
  end
end

