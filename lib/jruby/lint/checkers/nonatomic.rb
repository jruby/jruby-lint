module JRuby::Lint
  module Checkers
    class NonAtomic
      include Checker
      IVAR = org::jruby::ast::InstVarNode
      CVAR = org::jruby::ast::ClassVarNode

      OPERATORS = [:+, :-, :/, :*, :&, :|, :^, :>>, :<<, :%, :**]

      def visitOpAsgnOrNode(node)
        @last = node
        check_nonatomic(node, node.first_node)
      end

      def visitOpAsgnAndNode(node)
        @last = node
        check_nonatomic(node, node.first_node)
      end

      def visitOpElementAsgnNode(node)
        add_finding(collector, node, node)
      end

      def visitOpAsgnNode(node)
        check_nonatomic(node, node.receiver_node, node.variable_name)
      end

      def operator_op_assignment?(node, type)
        rhs = node.value_node
        rhs.kind_of?(org::jruby::ast::CallNode) &&
          OPERATORS.include?(rhs.name) &&
          rhs.receiver_node.kind_of?(type)
      end

      def visitInstAsgnNode(node)
        if !@last && operator_op_assignment?(node, IVAR) ||
           @last && parent != @last
          check_nonatomic(node, node)
        end
        @last = nil
      end

      def visitClassVarAsgnNode(node)
        if !@last && operator_op_assignment?(node, CVAR) ||
           @last && parent != @last
          check_nonatomic(node, node)
        end
        @last = nil
      end
      
      def check_nonatomic(orig_node, risk_node, name=nil)
        case risk_node
        when org::jruby::ast::LocalVarNode,
             org::jruby::ast::DVarNode
          # ok...mostly-safe cases
          false
        else
          add_finding(collector, orig_node, name || risk_node.name)
          true
        end
      end

      def add_finding(collector, node, name)
        collector.add_finding("Non-local operator assignment (#{name}) is not guaranteed to be atomic.", [:nonatomic, :warning], node.line+1)
      end
    end
  end
end
