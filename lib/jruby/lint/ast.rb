module JRuby::Lint
  module AST
    module Predicates
      METHOD_NODES = %w(CALLNODE FCALLNODE VCALLNODE)

      def method_calls_named(name, opts = {})
        only_type = opts[:type] && "#{opts[:type].to_s.upcase}NODE"
        node_types = METHOD_NODES.reject {|t| only_type && t != only_type }
        select {|n| node_types.include? n.node_type.to_s }
      end
    end

    class Visitor
      include Enumerable
      include Predicates
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

      def visit(node)
        @block.call(node) if @block
        node.child_nodes.each do |cn|
          cn.accept(self)
        end
      end

      def method_missing(name, *args, &block)
        if name.to_s =~ /^visit/
          visit(*args)
        else
          super
        end
      end
    end
  end
end
