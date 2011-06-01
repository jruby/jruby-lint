module JRuby::Lint
  module Checkers
    class System
      include Checker

      # Make sure to follow all Kernel.system calls
      def visitCallNode(node)
        if node.name == "system" || node.name == "`"
          @call_node = node
          add_finding(node) if red_flag?(node)
          proc { @call_node = nil }
        end
      end
      
      # Visits the function calls for system
      def visitFCallNode(node)
        if node.name == "system"
          add_finding(node) if red_flag?(node)
        end
      end
    
      def add_finding(node)
        collector.findings << Finding.new("Calling system('ruby * ') may cause awkward results",
                                          [:system, :warning], node.position)
      end
      
      # Defines red_flag when argument matches ruby
      def red_flag?(node)
        child = node.child_nodes.first
        child && 
        %w(ARRAYNODE CONSTNODE).include?(child.node_type.to_s) &&
        node.args_node[0].value =~ /^\s*ruby/
      end
    
    end
  end
end
