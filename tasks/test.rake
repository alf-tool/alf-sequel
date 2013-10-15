require "rspec/core/rake_task"
desc "Run unit tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = "spec/**/test_*.rb"
  t.rspec_opts = ["--color", "--backtrace", "-Ilib", "-Ispec"]
end
