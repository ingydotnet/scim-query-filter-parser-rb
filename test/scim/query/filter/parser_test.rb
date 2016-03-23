require 'test_helper'

require 'scim/query/filter/parser'
require 'json'

module SCIM
  module Query
    module Filter
      class ParserTest < Minitest::Test
        def parser
          @parser ||= SCIM::Query::Filter::Parser.new
        end

        def test_empty_string
          parser.parse("")

          rpn = parser.rpn
          assert_empty(rpn)

          tree = parser.tree
          assert_empty(tree)
        end

        def test_user_name_equals
          parser.parse(%Q(userName eq "bjensen"))

          rpn = parser.rpn
          assert_equal('userName', rpn[0])
          assert_equal('"bjensen"', rpn[1])
          assert_equal('eq', rpn[2])

          tree = parser.tree
          assert_equal('eq', tree[0])
          assert_equal('userName', tree[1])
          assert_equal('"bjensen"', tree[2])
        end

        def test_family_name_equals
          parser.parse(%Q(name.familyName co "O'Malley"))

          rpn = parser.rpn
          assert_equal('name.familyName', rpn[0])
          assert_equal(%Q("O'Malley"), rpn[1])
          assert_equal('co', rpn[2])

          tree = parser.tree
          assert_equal('co', tree[0])
          assert_equal('name.familyName', tree[1])
          assert_equal(%Q("O'Malley"), tree[2])
        end

        def test_user_name_starts_with
          parser.parse(%Q(userName sw "J"))

          rpn = parser.rpn
          assert_equal('userName', rpn[0])
          assert_equal(%Q("J"), rpn[1])
          assert_equal('sw', rpn[2])

          tree = parser.tree
          assert_equal('sw', tree[0])
          assert_equal('userName', tree[1])
          assert_equal('"J"', tree[2])
        end

        def test_title_present
          parser.parse(%Q(title pr))

          rpn = parser.rpn
          assert_equal('title', rpn[0])
          assert_equal('pr', rpn[1])

          tree = parser.tree
          assert_equal('pr', tree[0])
          assert_equal('title', tree[1])
        end

        def test_last_modified_greater_than
          parser.parse(%Q(meta.lastModified gt "2011-05-13T04:42:34Z"))

          rpn = parser.rpn
          assert_equal('meta.lastModified', rpn[0])
          assert_equal('"2011-05-13T04:42:34Z"', rpn[1])
          assert_equal('gt', rpn[2])

          tree = parser.tree
          assert_equal('gt', tree[0])
          assert_equal('meta.lastModified', tree[1])
          assert_equal('"2011-05-13T04:42:34Z"', tree[2])
        end

        def test_last_modified_greater_than_or_equal_to
          parser.parse(%Q(meta.lastModified ge "2011-05-13T04:42:34Z"))

          rpn = parser.rpn

          assert_equal('meta.lastModified', rpn[0])
          assert_equal('"2011-05-13T04:42:34Z"', rpn[1])
          assert_equal('ge', rpn[2])

          tree = parser.tree
          assert_equal('ge', tree[0])
          assert_equal('meta.lastModified', tree[1])
          assert_equal('"2011-05-13T04:42:34Z"', tree[2])
        end

        def test_last_modified_less_than
          parser.parse(%Q(meta.lastModified lt "2011-05-13T04:42:34Z"))

          rpn = parser.rpn

          assert_equal('meta.lastModified', rpn[0])
          assert_equal('"2011-05-13T04:42:34Z"', rpn[1])
          assert_equal('lt', rpn[2])

          tree = parser.tree
          assert_equal('lt', tree[0])
          assert_equal('meta.lastModified', tree[1])
          assert_equal('"2011-05-13T04:42:34Z"', tree[2])
        end

        def test_last_modified_less_than_or_equal_to
          parser.parse(%Q(meta.lastModified le "2011-05-13T04:42:34Z"))

          rpn = parser.rpn

          assert_equal('meta.lastModified', rpn[0])
          assert_equal('"2011-05-13T04:42:34Z"', rpn[1])
          assert_equal('le', rpn[2])

          tree = parser.tree
          assert_equal('le', tree[0])
          assert_equal('meta.lastModified', tree[1])
          assert_equal('"2011-05-13T04:42:34Z"', tree[2])
        end

        def test_title_and_user_type_equal
          parser.parse(%Q(title pr and userType eq "Employee"))

          rpn = parser.rpn

          assert_equal('title', rpn[0])
          assert_equal('pr', rpn[1])
          assert_equal('userType', rpn[2])
          assert_equal('"Employee"', rpn[3])
          assert_equal('eq', rpn[4])
          assert_equal('and', rpn[5])

          tree = parser.tree
          assert_equal(3, tree.count)
          assert_equal('and', tree[0])

          sub = tree[1]
          assert_equal(2, sub.count)
          assert_equal('pr', sub[0])
          assert_equal('title', sub[1])

          sub = tree[2]
          assert_equal(3, sub.count)
          assert_equal('eq', sub[0])
          assert_equal('userType', sub[1])
          assert_equal('"Employee"', sub[2])
        end

        def test_title_or_user_type_equal
          parser.parse(%Q(title pr or userType eq "Intern"))

          rpn = parser.rpn

          assert_equal('title', rpn[0])
          assert_equal('pr', rpn[1])
          assert_equal('userType', rpn[2])
          assert_equal('"Intern"', rpn[3])
          assert_equal('eq', rpn[4])
          assert_equal('or', rpn[5])

          tree = parser.tree
          assert_equal(3, tree.count)
          assert_equal('or', tree[0])

          sub = tree[1]
          assert_equal(2, sub.count)
          assert_equal('pr', sub[0])
          assert_equal('title', sub[1])

          sub = tree[2]
          assert_equal(3, sub.count)
          assert_equal('eq', sub[0])
          assert_equal('userType', sub[1])
          assert_equal('"Intern"', sub[2])
        end

        def test_compound_filter
          parser.parse(%Q{userType eq "Employee" and (emails co "example.com" or emails co "example.org")})

          rpn = parser.rpn

          assert_equal('userType', rpn[0])
          assert_equal('"Employee"', rpn[1])
          assert_equal('eq', rpn[2])
          assert_equal('emails', rpn[3])
          assert_equal('"example.com"', rpn[4])
          assert_equal('co', rpn[5])
          assert_equal('emails', rpn[6])
          assert_equal('"example.org"', rpn[7])
          assert_equal('co', rpn[8])
          assert_equal('or', rpn[9])
          assert_equal('and', rpn[10])

          tree = parser.tree
          assert_equal(3, tree.count)
          assert_equal('and', tree[0])

          sub = tree[1]
          assert_equal(3, sub.count)
          assert_equal('eq', sub[0])
          assert_equal('userType', sub[1])
          assert_equal('"Employee"', sub[2])

          sub = tree[2]
          assert_equal(3, sub.count)
          assert_equal('or', sub[0])

          assert_equal(3, sub[1].count)
          assert_equal('co', sub[1][0])
          assert_equal('emails', sub[1][1])
          assert_equal('"example.com"', sub[1][2])

          assert_equal(3, sub[2].count)
          assert_equal('co', sub[2][0])
          assert_equal('emails', sub[2][1])
          assert_equal('"example.org"', sub[2][2])
        end
      end
    end
  end
end
