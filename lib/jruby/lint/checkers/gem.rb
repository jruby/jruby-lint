module JRuby::Lint::Checkers
  module CheckGemNode
    def self.add_wiki_link_finding(collector)
      unless @added_wiki_link
        collector.add_finding("For more on gem compatibility see https://github.com/jruby/jruby/wiki/C-Extension-Alternatives", [:gems, :info]).tap do |f|
          def f.to_s
            message
          end
        end
        @added_wiki_link = true
      end
    end

    def gem_name(node)
      first_arg = node&.args_node&.child_nodes[0]
      first_arg.value.to_s if first_arg&.node_type&.to_s == "STRNODE"
    end

    def jruby_gem_entry?(node)
      node&.args_node&.child_nodes.each do |child|
        if child&.node_type&.to_s == "HASHNODE"
          child.pairs.each do |pair|
            return false if pair.key.name == :platform &&
                            pair.value.name != :jruby
          end
        end
      end

      # platform(:mri, ...) { gem 'rdiscount' }
      # FIXME: Esoteric use of platform(...) { group(...) {} } is still broken
      if grand_parent.kind_of?(org::jruby::ast::CallNode) &&
         grand_parent.name == :platforms
        grand_parent.args_node.child_nodes.each do |child|
          return false if child&.name != :jruby
        end
      end

      true  
    end

    def check_gem(collector, call_node)
      @gems ||= collector.project.libraries.gems
      gem_name = gem_name(call_node)
      if gem_name && jruby_gem_entry?(call_node) && instructions = @gems[gem_name]
        CheckGemNode.add_wiki_link_finding(collector)
        msg = "Found gem '#{gem_name}' which is reported to have some issues:\n#{instructions}"
        collector.add_finding(msg, [:gems, :warning], call_node.line+1)
      end
    end
  end

  class Gem
    include JRuby::Lint::Checker, CheckGemNode

    def visitFCallNode(node)
      check_gem(collector, node) if node.name == :gem
    end
  end
end
