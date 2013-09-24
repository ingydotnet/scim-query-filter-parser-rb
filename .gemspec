# encoding: utf-8

GemSpec ||= Gem::Specification.new do |gem|
  gem.name = 'scim-query-filter-parser'
  gem.version = '0.0.3'
  gem.license = 'MIT'
  gem.required_ruby_version = '>= 1.9.1'

  gem.authors << 'Ingy döt Net'
  gem.email = 'ingy@ingy.net'
  gem.summary = 'SCIM Filter Query Parser'
  gem.description = <<-'.'
A parser for SCIM filter queries. Specced here:
http://www.simplecloud.info/specs/draft-scim-api-01.html#query-resources
.
  gem.homepage = 'https://github.com/ingydotnet/scim-query-filter-parser-rb'

  gem.files = `git ls-files`.lines.map{|l|l.chomp}

  gem.add_development_dependency 'rake'
end
