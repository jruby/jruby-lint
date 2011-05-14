module JRuby::Lint
  module AST
    module MethodCalls
      def visitCallNode(node)
        visitMethodCallNode(node)
      end

      def visitFCallNode(node)
        visitMethodCallNode(node)
      end

      def visitVCallNode(node)
        visitMethodCallNode(node)
      end

      def visitAttrAssignNode(node)
        visitMethodCallNode(node)
      end
    end

    class Visitor
      include Enumerable
      include org.jruby.ast.visitor.NodeVisitor
      attr_reader :ast

      def initialize(ast)
        @ast = ast
      end

      def each(&block)
        @block = block
        ast.accept(self)
      ensure
        @block = nil
      end

      alias each_node each
      alias traverse each

      def visit(method, node)
        @block.call(node) if @block
        node.child_nodes.each do |cn|
          cn.accept(self) rescue nil
        end
      end

      def method_missing(name, *args, &block)
        if name.to_s =~ /^visit/
          visit(name, *args)
        else
          super
        end
      end
    end
  end
end
