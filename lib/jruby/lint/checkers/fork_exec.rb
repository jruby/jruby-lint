module JRuby::Lint
  module Checkers
    class ForkExec
      include Checker

      class Visitor < ::JRuby::Lint::AST::Visitor
        def initialize(collector)
          super(collector.ast)
          @collector = collector
        end

        def add_finding(node)
          msg = nil
          tags = [node.name]
          case node.name
          when 'fork'
            msg = 'Kernel#fork is not implemented on JRuby.'
            tags << :error
          when 'exec'
            msg = 'Kernel#exec does not replace the running JRuby process and may behave unexpectedly'
            tags << :warning
          end

          @collector.findings << Finding.new(msg, tags, node.position)
        end

        def visitCallNode(node)
          if fork_exec?(node)
            @call_node = node
            child = node.child_nodes.first
            if child && %w(COLON3NODE CONSTNODE).include?(child.node_type.to_s) && child.name == "Kernel"
              add_finding(node)
            end
          end
          super
        ensure
          @call_node = nil
        end

        def visitFCallNode(node)
          add_finding(node) if fork_exec?(node)
          super
        end

        def visitVCallNode(node)
          if fork_exec?(node)
            add_finding(node) unless @call_node
          end
          super
        end

        def fork_exec?(node)
          node.name == "fork" || node.name == "exec"
        end
      end

      def check(collector)
        Visitor.new(collector).traverse
      end
    end
  end
end
