module JRuby::Lint
  module Checkers
    class NonAtomic
      include Checker

      # ast trees like @foo ||= 1 is an opasgnor with a child instasgn.
      # the opasgn should mark itself as found and the an immediate instasgn
      # will not check since it is part of the opasgn.  If a child of that
      # contains another instasgn it will then still find it since we toggle
      # this off in instasgn.
      def within_op_asgn
        ret = @in_op_asgn
        @in_op_asgn = false if @in_op_asgn
        ret
      end

      def visitOpAsgnOrNode(node)
        @in_op_asgn = true
        check_nonatomic(node, node.first_node)
      end

      def visitOpAsgnAndNode(node)
        @in_op_asgn = true
        check_nonatomic(node, node.first_node)
      end

      def visitOpElementAsgnNode(node)
        add_finding(collector, node, node.name)
      end

      def visitOpAsgnNode(node)
        check_nonatomic(node, node.receiver_node)
      end

      def visitInstAsgnNode(node)
        check_nonatomic(node, node.receiver_node) unless within_op_asgn
      end

      def visitClassVarAsgnNode(node)
        check_nonatomic(node, node.receiver_node) unless within_op_asgn
      end
      
      def check_nonatomic(orig_node, risk_node)
        case risk_node
        when org::jruby::ast::LocalVarNode,
             org::jruby::ast::DVarNode
          # ok...mostly-safe cases
          false
        else
          add_finding(collector, orig_node, risk_node.name)
          true
        end
      end

      def add_finding(collector, node, name)
        collector.add_finding("Non-local operator assignment (#{name}) is not guaranteed to be atomic.", [:nonatomic, :warning], node.line+1)
      end
    end
  end
end
