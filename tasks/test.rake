require "rspec/core/rake_task"
desc "Run tests"
RSpec::Core::RakeTask.new(:test => :fixtures) do |t|
  t.pattern = "spec/**/test_*.rb"
  t.rspec_opts = ["--color"]
end
