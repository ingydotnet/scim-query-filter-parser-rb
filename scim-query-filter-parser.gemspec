$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'scim-query-filter-parser'
  s.version     = '0.0.2'
  s.authors     = ['Ingy döt Net']
  s.email       = ['ingy@ingy.net']
  s.homepage    = 'https://github.com/ingydotnet/scim-query-filter-parser-rb'
  s.summary     = 'SCIM Filter Query Parser'
  s.description = <<-TXT
A parser for SCIM filter queries. Specced here:
http://www.simplecloud.info/specs/draft-scim-api-01.html#query-resources
TXT
  s.license     = 'MIT'

  s.files = Dir["{lib}/**/*", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
end
