module JRuby::Lint
  module Checkers
    module CheckGemNode
      def gem_name(node)
        first_arg = node.args_node.child_nodes[0]
        if first_arg.node_type.to_s == "STRNODE"
          first_arg.value.to_s
        end
      rescue
        nil
      end

      def check_gem(collector, call_node)
        @gems ||= collector.project.gems_info.gems
        gem_name = gem_name(call_node)
        if instructions = @gems[gem_name]
          msg = "Found gem '#{gem_name}' which is reported to have some issues:\n#{instructions}"
          collector.findings << Finding.new(msg, [:gems, :warning], call_node.position)
        end
      end
    end

    class Gem
      include Checker
      include CheckGemNode

      def check(collector)
        visitor = ::JRuby::Lint::AST::Visitor.new(collector.ast)
        visitor.method_calls_named('gem', :type => :fcall).each do |node|
          check_gem(collector, node)
        end
      end
    end
  end
end
