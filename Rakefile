require "bundler/gem_tasks"

task default: :test
task test: %i[rubocop spec]

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: :spec
rescue LoadError
  puts "RSpec is unavailable"
end

require "rubocop/rake_task"
RuboCop::RakeTask.new
