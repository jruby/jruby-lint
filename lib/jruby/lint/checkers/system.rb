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
        collector.findings << Finding.new("Calling Kernel.system('ruby ...') will get called in-process.  Sometimes this works differently than expected",
                                          [:system, :warning], node.position)
      end
      
      # Defines red_flag when argument matches ruby
      def red_flag?(node)
        child = node.child_nodes.first
        child && 
        %w(ARRAYNODE CONSTNODE).include?(child.node_type.to_s) &&
        ruby_executable?(node)
      end
      
      def ruby_executable?(node)
        match_on = Regexp.union([/^\s*ruby/i, /\s*j?irb\s*$/i, /\.rb$/i])
        node.args_node[0].value =~ match_on
      end
    end
  end
end
