module Ameba::AST
  # A generic entity to represent a branchable Crystal node.
  # For example, `Crystal::If`, `Crystal::Unless`, `Crystal::While`
  # are branchable.
  #
  # ```
  # white a > 100 # Branchable A
  #   if b > 2    # Branchable B
  #     a += 1
  #   end
  # end
  # ```
  class Branchable
    getter branches = [] of Crystal::ASTNode

    # The actual Crystal node.
    getter node : Crystal::ASTNode

    # Parent branchable (if any)
    getter parent : Branchable?

    delegate to_s, to: @node
    delegate location, to: @node

    # Creates a new branchable
    #
    # ```
    # Branchable.new(node, parent_branchable)
    # ```
    def initialize(@node, @parent = nil)
    end

    # Returns true if this node or one of the parent branchables is a loop, false otherwise.
    def loop?
      return true if node.is_a? Crystal::While ||
                     node.is_a? Crystal::Until ||
                     ((n = node) && n.is_a?(Crystal::Call) && n.name == "loop")

      parent.try(&.loop?) || false
    end
  end
end
