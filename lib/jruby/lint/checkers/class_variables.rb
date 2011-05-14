module JRuby::Lint
  module Checkers
    class ClassVariables
      include Checker

      def visitClassVarAsgnNode(node)
        collector.findings << Finding.new("Assigning to class variables in a method might not be thread-safe",
                                          [:threads, :warning], node.position)
      end
    end
  end
end
