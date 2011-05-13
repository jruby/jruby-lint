module JRuby::Lint
  module Checkers
    class Gemspec
      include Checker

      class Visitor < ::JRuby::Lint::AST::Visitor
        include CheckGemNode

        def initialize(collector)
          super(collector.ast)
          @collector = collector
        end

        def visitStrNode(node)
          super
        end

        def visitCallNode(node)
          # Gem::Specification.new do |s| =>
          #
          #     CallNoArgBlockNode |new|
          #       Colon2ConstNode |Specification|
          #       IterNode
          #         DAsgnNode |s| &0 >0
          #           NilImplicitNode |nil|
          #         BlockNode
          if node.name == "new" && # new
              node.args_node.nil? && # no args
              node.iter_node && # with a block
              node.receiver_node.node_type.to_s == "COLON2NODE" && # :: - Colon2
              node.receiver_node.name == "Specification" &&        # ::Specification
              node.receiver_node.left_node.name == "Gem"           # Gem::Specification
            @gemspec_block_var = node.iter_node.var_node.name
            begin
              super
            ensure
              @gemspec_block_var = nil
            end
            return
          end

          # s.add_dependency "rdiscount" =>
          #
          #     CallOneArgNode |add_dependency|
          #       DVarNode |s| &0 >0
          #       ArrayNode
          #         StrNode =="rdiscount"
          if @gemspec_block_var &&
              node.name == "add_dependency" &&
              node.receiver_node.name == @gemspec_block_var
            check_gem(@collector, node)
          end
        rescue
          super
        end
      end

      def check(collector)
        Visitor.new(collector).traverse
      end
    end
  end
end
