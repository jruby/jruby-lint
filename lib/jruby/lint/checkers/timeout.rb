class JRuby::Lint::Checkers::Timeout
  include JRuby::Lint::Checker

  def visitCallNode(node)
    if node.name == :timeout
      collector.add_finding("Timeout in JRuby does not work in many cases",
                            [:timeout, :warning], node.line+1)
    end
  end
end
