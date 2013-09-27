namespace :test do
  require "rspec/core/rake_task"

  desc "Run unit tests"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/test_*.rb"
    t.rspec_opts = ["--color", "--backtrace"]
  end

  desc "Run integration tests"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "spec/integration/**/test_*.rb"
    t.rspec_opts = ["--color", "--backtrace"]
  end

end
task :test => [:"test:unit", :"test:integration"]