require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::AST::Visitor do
  Given(:ast) { JRuby.parse(script) }
  Given(:visitor) { JRuby::Lint::AST::Visitor.new(ast) }

  # RootNode
  #   FCallOneArgNode |puts|
  #     ArrayNode
  #       StrNode =="hello"
  Given(:script) { %{puts "hello"} }

  context "visits all nodes" do
    When { visitor.each_node { @count ||= 0; @count += 1} }
    Then { expect(@count).to eq(4) }
  end

  context "selects nodes" do
    When { @nodes = visitor.select {|n| n.node_type == org.jruby.ast.NodeType::STRNODE } }
    Then { expect(@nodes.size).to(eq(1)) &&
           expect(@nodes.first.value.to_s).to(eq("hello")) }
  end
end
