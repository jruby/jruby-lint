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
        first_arg = node.args_node.child_nodes.first
        first_arg && first_arg.node_type.to_s == "STRNODE" && ruby_executable?(first_arg)
      end

      def ruby_executable?(node)
        match_on = Regexp.union([/.*ruby$/i, /.*j?irb$/i, /\.rb$/i])
        node.value.split.first =~ match_on
      end
    end
  end
end
