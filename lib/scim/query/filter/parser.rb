class SCIM; class Query; class Filter; class Parser; end; end; end; end

class SCIM::Query::Filter::Parser
  attr_accessor :rpn

  Ops = {
    'eq' => 3,
    'co' => 3,
    'sw' => 3,
    'pr' => 4,
    'gt' => 3,
    'ge' => 3,
    'lt' => 3,
    'le' => 3,
    'and' => 2,
    'or' => 1,
  }
  Unary = {
    'pr' => 1,
  }

  Paren = /[\(\)]/
  Str = /"(?:\\"|[^"])*"/
  Op = /#{Ops.keys.join'|'}/
  Word = /[\w\.]+/
  Sep = /\s?/
  Token = /^(#{Paren}|#{Str}|#{Op}|#{Word})#{Sep}/

  def parse input
    @input = input.clone            # Save for error msgs
    @tokens = lex input
    @rpn = parse_expr
    assert_eos
    self
  end

  def parse_expr
    ast = []
    want_op = false
    while not eos and peek != ')'
      want_op && assert_op || assert_not_op
      ast.push(start_group ? parse_group : pop)
      want_op ^= true unless Unary[ast.last]
    end
    to_rpn ast
  end

  def parse_group
    pop                 # pop '(' token
    ast = parse_expr
    assert_close && pop # pop ')' token
    ast
  end

  # Split input into tokens
  def lex input
    tokens = []
    while ! input.empty? do
      input.sub! Token, '' \
        or fail "Can't lex input here '#{input}'"
      tokens.push $1
    end
    tokens
  end


  # Turn parsed tokens into an RPN stack
  # http://en.wikipedia.org/wiki/Shunting_yard_algorithm
  def to_rpn ast
    out, ops = [], []
    out.push ast.shift if not ast.empty?
    while not ast.empty? do
      op = ast.shift
      p = Ops[op] \
        or fail "Unknown operator '#{op}'"
      while not ops.empty? do
        break if p > Ops[ops.first]
        out.push ops.shift
      end
      ops.unshift op
      out.push ast.shift if not Unary[op]
    end
    (out.concat ops).flatten
  end

  # Transform RPN stack into a tree structure
  def tree
    @stack = @rpn.clone
    get_tree
  end

  def get_tree
    tree = []
    if not @stack.empty?
      op = tree[0] = @stack.pop
      tree[1] = Ops[@stack.last] ? get_tree : @stack.pop
      if not Unary[op]
        tree[2] = tree[1]
        tree[1] = Ops[@stack.last] ? get_tree : @stack.pop
      end
    end
    tree
  end

  # Token sugar methods
  def peek; @tokens.first  end
  def pop;  @tokens.shift  end
  def eos;  @tokens.empty? end
  def start_group; peek == '(' end
  def peek_operator
    not(eos) and peek.match /^(?:#{Op})$/
  end


  # Error handling methods:
  def parse_error msg
    fail "#{sprintf(msg, *@tokens, 'EOS')}.\nInput: '#{@input}'\n"
  end

  def assert_op
    parse_error "Unexpected token '%s'. Expected operator" \
      if ! peek_operator
    true
  end

  def assert_not_op
    parse_error "Unexpected operator '%s'" \
      if peek_operator
    true
  end

  def assert_close
    parse_error "Unexpected token '%s'. Expected ')'" \
      unless peek == ')'
    true
  end

  def assert_eos
    parse_error "Unexpected token '%s'. Expected EOS" \
      if peek
    true
  end

end
