module JRuby::Lint
  module Checkers
    class ClassVariables
      include Checker

      def check(collector)
        visitor = ::JRuby::Lint::AST::Visitor.new(collector.ast)
        visitor.select {|node| node.node_type.to_s == "CLASSVARASGNNODE" }.each do |node|
          collector.findings << Finding.new("Assigning to class variables in a method might not be thread-safe",
                                            [:threads, :warning], node.position)
        end
      end
    end
  end
end
