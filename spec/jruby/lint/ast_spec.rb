require File.expand_path('../../../spec_helper', __FILE__)

describe JRuby::Lint::AST::Visitor do
  Given(:ast) { JRuby.parse(script) }
  Given(:visitor) { JRuby::Lint::AST::Visitor.new(ast) }

  # RootNode
  #   NewlineNode
  #     FCallOneArgNode |puts|
  #       ArrayNode
  #         StrNode =="hello"
  Given(:script) { %{puts "hello"} }

  context "visits all nodes" do
    When { visitor.each_node { @count ||= 0; @count += 1} }
    Then { @count.should == 5 }
  end

  context "selects nodes" do
    When { @nodes = visitor.select {|n| n.node_type == org.jruby.ast.NodeType::STRNODE } }
    Then { @nodes.size.should == 1 && @nodes.first.value.to_s.should == "hello" }
  end

  context "selects methods by name" do
    When { @nodes = visitor.method_calls_named("puts") }
    Then { @nodes.size.should == 1 }
  end

  context "selects methods by name and specific type" do
    Given(:script) { %{object.puts 1; puts 2} }
    When { @nodes = visitor.method_calls_named("puts", :type => :fcall) }
    Then { @nodes.size.should == 1 }
  end
end
