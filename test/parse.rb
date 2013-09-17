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
      rpn_yaml = data.shift or break
      parser.parse(input)
      got_rpn_json = parser.rpn.to_json
      want_rpn_json = YAML.load(rpn_yaml).to_json
      puts got_rpn_json
#       assert_equal want_rpn_json, got_rpn_json,
#         "Test parse: '#{input.chomp}'"
      line = data.shift or break
      fail "Got '#{line.chomp}', expected blank line" \
        unless line == "\n"
    end
  end
end

$test_parse_data = <<'...'
userName eq "bjensen"
[userName,'"bjensen"',eq]

name.familyName co "O'Malley"
[]

userName sw "J"
[]

title pr
[]

meta.lastModified gt "2011-05-13T04:42:34Z"
[]

meta.lastModified ge "2011-05-13T04:42:34Z"
[]

meta.lastModified lt "2011-05-13T04:42:34Z"
[]

meta.lastModified le "2011-05-13T04:42:34Z"
[]

title pr and userType eq "Employee"
[]

title pr or userType eq "Intern"
[]

userType eq "Employee" and (emails co "example.com" or emails co "example.org")
[]
...

