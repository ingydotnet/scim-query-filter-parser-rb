require 'bundler/gem_tasks'

require 'rake'
require 'rake/clean'

desc 'Run all of the tests'
task :test do
  $LOAD_PATH.unshift('lib', 'test')

  Dir.glob('./test/**/*_test.rb') { |f| require f }
end

task :default => 'test'
