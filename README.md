![Gem Version](https://badge.fury.io/rb/scim-query-filter-parser.png)
![Travis](https://travis-ci.org/ingydotnet/scim-query-filter-parser-rb.png)

# SCIM Query Filter Parser

Parser for SCIM Filter Query Strings

# Synopsis

```ruby
require 'scim/query/filter/parser'

parser = SCIM::Query::Filter::Parser.new
rpn_array = parser.parse(filter_query_string)
rpn_stack = parser.rpn
rpn_tree = parser.tree

# or (in a single statement):
rpn_array = SCIM::Query::Filter::Parser.new.parse(filter_query_string).rpn
```

# Description

[The SCIM spec](http://www.simplecloud.info/specs/draft-scim-api-01.html#query-resources)
describes a simple filter query language.

This gem can parse one of these filter queries and produce a Reverse Polish
Notation (RPN) stack representation.

For example, parse this filter query string:

```
userType eq "Employee" and (emails co "example.com" or emails co "example.org")
```

Into this RPN stack (array):

```ruby
[
  'userType',
  '"Employee"',
  'eq',
  'emails',
  '"example.com"',
  'co',
  'emails',
  '"example.org"',
  'co',
  'or',
  'and'
]
```

Or, optionally into this expression tree:

```ruby
[
  'and',
  [
    'eq',
    'userType',
    '"Employee"'
  ],
  [
    'or',
    [
      'co',
      'emails',
      '"example.com"'
    ],
    [
      'co',
      'emails',
      '"example.org"'
    ]
  ]
]
```

# Methods

## `SCIM::Query::Filter::Parser.new`

Creae a new parser object.

## `SCIM::Query::Filter::Parser#parse(input)`

Parse a SCIM filter query. Return the parser object (self) if successful.

## `SCIM::Query::Filter::Parser#rpn`

Get the RPN array created by the most recent parse.

## `SCIM::Query::Filter::Parser#tree`

Get the parse result converted to a tree form.

# Copyright

Copyright (c) 2013 Ingy döt Net. See [LICENSE](./LICENSE) for further details.
