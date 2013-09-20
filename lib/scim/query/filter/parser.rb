class SCIM; class Query; class Filter; class Parser; end; end; end; end

class SCIM::Query::Filter::Parser
  attr_accessor :rpn

  #----------------------------------------------------------------------------
  # Operator Precedence:
  Ops = {
    'pr' => 4,
    'eq' => 3,
    'co' => 3,
    'sw' => 3,
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

  # Tokenizing regexen:
  Paren = /[\(\)]/
  Str = /"(?:\\"|[^"])*"/
  Op = /#{Ops.keys.join'|'}/
  Word = /[\w\.]+/
  Sep = /\s?/
  NextToken = /^(#{Paren}|#{Str}|#{Op}|#{Word})#{Sep}/
  IsOperator = /^(?:#{Op})$/

  #----------------------------------------------------------------------------
  # Parse SCIM filter query into RPN stack:
  def parse input
    @input = input.clone            # Save for error msgs
    @tokens = lex input
    @rpn = parse_expr
    assert_eos
    self
  end

  def parse_expr
    ast = []
    expect_op = false
    while not eos and peek != ')'
      expect_op && assert_op || assert_not_op
      ast.push(start_group ? parse_group : pop)
      expect_op ^= true unless Unary[ast.last]
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
    input = input.clone
    tokens = []
    while ! input.empty? do
      input.sub! NextToken, '' \
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

  #----------------------------------------------------------------------------
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
      tree.insert 1, Ops[@stack.last] ? get_tree : @stack.pop \
        if not Unary[op]
    end
    tree
  end

  #----------------------------------------------------------------------------
  # Token sugar methods
  def peek; @tokens.first  end
  def pop;  @tokens.shift  end
  def eos;  @tokens.empty? end
  def start_group; peek == '(' end
  def peek_operator
    not(eos) and peek.match IsOperator
  end


  # Error handling methods:
  def parse_error msg
    fail "#{sprintf(msg, *@tokens, 'EOS')}.\nInput: '#{@input}'\n"
  end

  def assert_op
    return true if peek_operator
    parse_error "Unexpected token '%s'. Expected operator"
  end

  def assert_not_op
    return true if ! peek_operator
    parse_error "Unexpected operator '%s'"
  end

  def assert_close
    return true if peek == ')'
    parse_error "Unexpected token '%s'. Expected ')'"
  end

  def assert_eos
    return true if eos
    parse_error "Unexpected token '%s'. Expected EOS"
  end
end
