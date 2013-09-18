require 'scim/query/filter/parser'
require 'test/unit'
require 'yaml'
require 'json'

class TestParser < Test::Unit::TestCase
  def test_spec
    data = $test_parse_data.lines.to_a
    parser = SCIM::Query::Filter::Parser.new
    while true do
      input = data.shift or break
      input.chomp!
      rpn_yaml = data.shift or break
      next if rpn_yaml == "\n"
      parser.parse(input)
      got_rpn_json = parser.rpn.to_json
      want_rpn_json = YAML.load(rpn_yaml).to_json
      assert_equal want_rpn_json, got_rpn_json,
        "Test parse to RPN: '#{input.chomp}'"
      tree_yaml = data.shift or break
      next if tree_yaml == "\n"
      got_tree_json = parser.tree.to_json
      want_tree_json = YAML.load(tree_yaml).to_json
      assert_equal want_tree_json, got_tree_json,
        "Test parse to tree: '#{input.chomp}'"
      blank_line = data.shift or break
      fail "Got '#{blank_line.chomp}', expected blank line" \
        unless blank_line == "\n"
    end
  end
end

# See http://www.simplecloud.info/specs/draft-scim-api-01.html#query-resources
$test_parse_data = <<'...'

[]
[]

userName eq "bjensen"
[userName,'"bjensen"',eq]
[eq, userName,'"bjensen"']

name.familyName co "O'Malley"
[name.familyName, '"O''Malley"', co]
[co, name.familyName, '"O''Malley"']

userName sw "J"
[userName, '"J"', sw]
[sw, userName, '"J"']

title pr
[title, pr]
[pr, title]

meta.lastModified gt "2011-05-13T04:42:34Z"
[meta.lastModified, '"2011-05-13T04:42:34Z"', gt]
[gt, meta.lastModified, '"2011-05-13T04:42:34Z"']

meta.lastModified ge "2011-05-13T04:42:34Z"
[meta.lastModified, '"2011-05-13T04:42:34Z"', ge]
[ge, meta.lastModified, '"2011-05-13T04:42:34Z"']

meta.lastModified lt "2011-05-13T04:42:34Z"
[meta.lastModified, '"2011-05-13T04:42:34Z"', lt]
[lt, meta.lastModified, '"2011-05-13T04:42:34Z"']

meta.lastModified le "2011-05-13T04:42:34Z"
[meta.lastModified, '"2011-05-13T04:42:34Z"', le]
[le, meta.lastModified, '"2011-05-13T04:42:34Z"']

title pr and userType eq "Employee"
[title, pr, userType, '"Employee"', eq, and]
[and, [pr, title], [eq, userType, '"Employee"']]

title pr or userType eq "Intern"
[title, pr, userType, '"Intern"', eq, or]
[or, [pr, title], [eq, userType, '"Intern"']]

userType eq "Employee" and (emails co "example.com" or emails co "example.org")
[userType, '"Employee"', eq, emails, '"example.com"', co, emails, '"example.org"', co, or ,and]
[and, [eq, userType, '"Employee"'], [or, [co, emails, '"example.com"'], [co, emails, '"example.org"']]]
...
