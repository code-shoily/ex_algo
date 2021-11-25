defprotocol ExAlgo.Tree.Traversal do
  @spec inorder(t()) :: [any()]
  def inorder(tree)

  @spec preorder(t()) :: [any()]
  def preorder(tree)

  @spec postorder(t()) :: [any()]
  def postorder(tree)
end
