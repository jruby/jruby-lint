module JRuby::Lint
  module Checkers
    class Gemspec
      include Checker
      include CheckGemNode
      include AST::Helpers

      def initialize
        @gemspec_block_var = nil
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
          arg_node = find_first(node.iter_node.var_node) {|n| n.respond_to?(:name) }
          @gemspec_block_var = arg_node.name
          return proc { @gemspec_block_var = nil }
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
          check_gem(collector, node)
        end
      rescue
      end
    end
  end
end
