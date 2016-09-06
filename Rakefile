require "rubygems"
require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rake/testtask"

# Run the test with "rake" or "rake test"
desc "Default: run acts_as_type unit tests."
task default: :test

desc "Test the acts_as_type plugin."
Rake::TestTask.new(:test) do |t|
  t.libs << "lib" << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end

begin
  # Run the rdoc task to generate rdocs for this gem
  require "rdoc/task"
  RDoc::Task.new do |rdoc|
    require "acts_as_type/version"
    version = ActsAsType::VERSION

    rdoc.rdoc_dir = "rdoc"
    rdoc.title = "acts_as_type #{version}"
    rdoc.rdoc_files.include("README*")
    rdoc.rdoc_files.include("lib/**/*.rb")
  end
rescue LoadError
  puts "RDocTask is not supported on this platform."
rescue StandardError
  puts "RDocTask is not supported on this platform."
end