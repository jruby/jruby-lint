module JRuby::Lint
  module Checkers
    class Gem
      include Checker

      def check(collector)
        gems = nil
        visitor = ::JRuby::Lint::AST::Visitor.new(collector.ast)
        visitor.method_calls_named('gem', :type => :fcall).each do |node|
          gems ||= collector.project.gems_info.gems
          if msg = gems[gem_name(node)]
            collector.findings << Finding.new(msg, [:gems, :warning], node)
          end
        end
      end

      def gem_name(node)
        first_arg = node.args_node.child_nodes[0]
        if first_arg.node_type.to_s == "STRNODE"
          first_arg.value.to_s
        end
      rescue
        nil
      end
    end
  end
end
