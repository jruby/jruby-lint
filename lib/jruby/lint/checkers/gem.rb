module JRuby::Lint
  module Checkers
    module CheckGemNode
      def self.add_wiki_link_finding(collector)
        unless @added_wiki_link
          collector.findings << Finding.new("For more on gem compatibility see http://wiki.jruby.org/C-Extension-Alternatives",
                                            [:gems, :info]).tap do |f|
            def f.to_s
              message
            end
          end
          @added_wiki_link = true
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

      def check_gem(collector, call_node)
        @gems ||= collector.project.libraries.gems
        gem_name = gem_name(call_node)
        if instructions = @gems[gem_name]
          CheckGemNode.add_wiki_link_finding(collector)
          msg = "Found gem '#{gem_name}' which is reported to have some issues:\n#{instructions}"
          collector.findings << Finding.new(msg, [:gems, :warning], call_node.position)
        end
      end
    end

    class Gem
      include Checker
      include CheckGemNode

      def visitFCallNode(node)
        check_gem(collector, node) if node.name == "gem"
      end
    end
  end
end
