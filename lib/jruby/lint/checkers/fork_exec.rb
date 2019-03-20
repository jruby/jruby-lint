class JRuby::Lint::Checkers::ForkExec
  include JRuby::Lint::Checker

  def visitCallNode(node)
    if fork?(node)
      @call_node = node
      child = node.child_nodes.first
      if child && %w(COLON3NODE CONSTNODE).include?(child.node_type.to_s) && child.name == :Kernel
        add_finding(node)
      end
      proc { @call_node = nil }
    end
  end

  def visitFCallNode(node)
    add_finding node if fork?(node)
  end

  def visitVCallNode(node)
    add_finding node if fork?(node) && !@call_node
  end

  def fork?(node)
    node.name == :fork
  end

  def add_finding(node)
    collector.add_finding('Kernel#fork is not implemented on JRuby.', [:fork, :error], node.line+1)
  end
end
