import tables
type
  TreeNode = ref object of RootObj
    data: char
    children: Table[int, TreeNode]
    is_prefix_end: bool
  Trie* = ref object of RootObj
    dict_size: int
    root: TreeNode

proc newTreeNode(data: char, children_size: int): TreeNode =
  new(result)
  result.data = data
  result.children = initTable[int, TreeNode]()
  result.is_prefix_end = false
  #for i in 0..children_size-1:
  #  result.children.add(nil)

proc getAtChar(children: var Table[int, TreeNode], idx: char): TreeNode =
  let real_idx = idx.int - 97
  #while children.len < real_idx+1: # need to add more slots
  #  children.add(nil)
  if not children.hasKey(real_idx):
    return nil

  return children[real_idx]

proc createAtChar(children: var Table[int, TreeNode], idx: char, size: int): TreeNode =
  children[idx.int - 97] = newTreeNode(idx, size)
  return children.getAtChar(idx)

proc add_word*(trie: Trie, word: string): Trie {.discardable.} =
  var tree = trie.root
  for c in word:
    var nextCharTree = tree.children.getAtChar(c)
    if nextCharTree == nil:
      nextCharTree = tree.children.createAtChar(c, trie.dict_size)
    tree = tree.children.getAtChar(c)
  tree.is_prefix_end = true
  return trie

proc find_word*(trie: Trie, word: string): bool =
  var nextTree = trie.root
  for c in word:
    if nextTree.children.getAtChar(c) != nil:
      nextTree = nextTree.children.getAtChar(c)
    else:
      return false
  return nextTree.is_prefix_end

proc traverse(tree: TreeNode, curPath: var string, all_words: var seq[string]): string =
  var allChildrenNil = true
  for child in tree.children.values:
    if child != nil:
      allChildrenNil = false
      var nextPath = curPath
      nextPath.add($child.data)
      let addit = traverse(child, nextPath, all_words)
      if addit != nil:
        all_words.add(addit)
  if allChildrenNil or tree.is_prefix_end:
    return curPath

proc get_all_words*(trie: Trie): seq[string] =
  var s = ""
  result = @[]
  discard traverse(trie.root, s, result)

proc count_non_nil_nodes(tree: TreeNode): int =
  result = 1 # ourself
  for child in tree.children.values:
    if child != nil:
      result += count_non_nil_nodes(child)

proc get_node_count*(trie: Trie): int =
  ## returns the number of non-nil nodes.
  return count_non_nil_nodes(trie.root)

proc count_space_used(tree: TreeNode): int =
  ## space is sizeof tree node plus sizeof tree node * children.length
  result = TreeNode.sizeof * (1 + tree.children.len)
  for child in tree.children.values:
    if child != nil:
      result += count_space_used(child)

proc count_space_used*(trie: Trie): int =
  return count_space_used(trie.root)

proc newTrie*(dict_size: int, initial_dict: seq[string]): Trie =
  new(result)
  result.dict_size = dict_size
  result.root = newTreeNode('\0', dict_size)
  for word in initial_dict:
    result.add_word(word)

when isMainModule:
  let dictionary = @["hello", "world", "i", "like", "pudding", "and", "please", "send", "help"]
  let trie = newTrie(26, dictionary)
  echo trie.get_node_count()
  echo trie.count_space_used()
  trie.add_word("puny")
  echo trie.get_node_count()
  echo trie.count_space_used()
  echo trie.find_word("hello")
  echo trie.find_word("ape")
  echo trie.find_word("zing")
  echo trie.find_word("puny")
  echo trie.find_word("help")
  echo $trie.get_all_words()
  echo trie.find_word("hell")
  trie.add_word("hell")
  echo trie.get_node_count()
  echo trie.count_space_used()
  echo trie.find_word("hell")
  echo $trie.get_all_words()
  echo "now testing /usr/share/dict/words"

  import strutils
  let dict_trie = newTrie(26, @[])
  let dfile = open("/usr/share/dict/words")
  var dict_seq: seq[string] = @[]
  var dict_seq_size = 0
  var word_count = 0
  for word in dfile.lines:
    if word.len < 15:
      dict_trie.add_word(word.toLower)
      dict_seq.add(word.toLower)
      if not dict_trie.find_word(word.toLower):
        echo "Oops..."
      dict_seq_size += word.len * char.sizeof + 1
      word_count += 1
  echo word_count, " words"
  echo dict_seq_size, " bytes for perfect seq"
  echo dict_trie.count_space_used(), " bytes for trie"
  echo dict_trie.get_node_count(), " non-nil nodes for trie"

