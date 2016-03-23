module SCIM
  module Query
    module Filter
      class Parser
        class Error < StandardError
        end

        attr_accessor :rpn

        #----------------------------------------------------------------------------
        # Operator Precedence:
        OPS = {
          'pr' => 4,
          'eq' => 3,
          'co' => 3,
          'sw' => 3,
          'gt' => 3,
          'ge' => 3,
          'lt' => 3,
          'le' => 3,
          'and' => 2,
          'or' => 1
        }.freeze

        UNARY = {
          'pr' => 1
        }.freeze

        # Tokenizing regexen:
        PAREN = /[\(\)]/.freeze
        STR = /"(?:\\"|[^"])*"/.freeze
        OP = /#{OPS.keys.join('|')}/.freeze
        WORD = /[\w\.]+/.freeze
        SEP = /\s?/.freeze
        NEXT_TOKEN = /\A(#{PAREN}|#{STR}|#{OP}|#{WORD})#{SEP}/.freeze
        IS_OPERATOR = /\A(?:#{OP})\Z/.freeze

        # Parse SCIM filter query into RPN stack
        #
        # @param input [String]
        #
        # @return [SCIM::Query::Filter::Parser]
        def parse(input)
          # Save for error msgs
          @input = input.clone
          @tokens = lex(input)
          @rpn = parse_expr

          assert_eos

          self
        end

        def parse_expr
          ast = []
          expect_op = false
          while !eos && peek != ')'
            expect_op && assert_op || assert_not_op

            ast.push(start_group ? parse_group : pop)

            unless UNARY[ast.last]
              expect_op ^= true
            end
          end

          to_rpn(ast)
        end

        def parse_group
          # pop '(' token
          pop

          ast = parse_expr

          # pop ')' token
          assert_close && pop

          ast
        end

        # Split input into tokens
        #
        # @param input [String]
        #
        # @return [Array<String>]
        def lex(input)
          input = input.clone
          tokens = []

          until input.empty? do
            input.sub!(NEXT_TOKEN, '') || fail(Error, "Can't lex input here '#{input}'")

            tokens.push($1)
          end
          tokens
        end

        # Turn parsed tokens into an RPN stack
        #
        # @see http://en.wikipedia.org/wiki/Shunting_yard_algorithm
        #
        # @param ast [Array]
        def to_rpn(ast)
          out = []
          ops = []

          out.push(ast.shift) unless ast.empty?

          until ast.empty? do
            op = ast.shift
            p = OPS[op] || fail(Error "Unknown operator '#{op}'")

            until ops.empty? do
              break if p > OPS[ops.first]
              out.push(ops.shift)
            end

            ops.unshift(op)
            out.push(ast.shift) unless UNARY[op]
          end
          (out.concat(ops)).flatten
        end

        #----------------------------------------------------------------------------
        # Transform RPN stack into a tree structure
        def tree
          @stack = @rpn.clone
          get_tree
        end

        def get_tree
          tree = []
          unless @stack.empty?
            op = tree[0] = @stack.pop
            tree[1] = OPS[@stack.last] ? get_tree : @stack.pop

            unless UNARY[op]
              tree.insert(1, (OPS[@stack.last] ? get_tree : @stack.pop))
            end
          end
          tree
        end

        # Token sugar methods
        def peek
          @tokens.first
        end

        def pop
          @tokens.shift
        end

        def eos
          @tokens.empty?
        end

        def start_group
          peek == '('
        end

        def peek_operator
          !eos && peek.match(IS_OPERATOR)
        end

        # Error handling methods:
        def parse_error msg
          fail(Error, "#{sprintf(msg, *@tokens, 'EOS')}.\nInput: '#{@input}'\n")
        end

        def assert_op
          return true if peek_operator
          parse_error("Unexpected token '%s'. Expected operator")
        end

        def assert_not_op
          return true unless peek_operator
          parse_error("Unexpected operator '%s'")
        end

        def assert_close
          return true if peek == ')'
          parse_error("Unexpected token '%s'. Expected ')'")
        end

        def assert_eos
          return true if eos
          parse_error("Unexpected token '%s'. Expected EOS")
        end
      end
    end
  end
end
