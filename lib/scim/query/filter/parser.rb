class SCIM; class Query; class Filter; class Parser; end; end; end; end

class SCIM::Query::Filter::Parser
  Precedence = {
    eq: 1,
    co: 1,
    sw: 1,
    pr: 1,
    gt: 1,
    ge: 1,
    lt: 1,
    le: 1,
    and: 2,
    or: 3,
  }

  Paren = /[\(\)]/
  Word = /[\w\.]+/
  Op = /#{Precedence.keys.join'|'}/
  Str = /"(\\"|[^"])*"/
  Sep = /\s?/
  Token = /^(#{Paren}|#{Str}|#{Op}|#{Word})#{Sep}/

  def parse input
    self.lex input
    @stack = []
    return self if @tokens.empty?
#     error "Unexpected operator '%s'" if peek_operator
#     parse_list if peek == '('
    return self
  end

  def rpn
    @tokens
  end

  def tree

  end

  def lex input
    @input = input
    @tokens = []
    while ! input.empty? do
      input.sub! Token, '' \
        or fail "Can't lex input here '#{input}'"
      @tokens.push $1
    end
  end
end
