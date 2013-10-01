namespace :bench do

  def bench_cmd
    "ALF_TEST_ENV=postgres bundle exec ruby -Ilib bench/bench_all.rb"
  end

  def alf_cmd(tail)
    "bundle exec alf --ff=%.6f --input-reader=rash #{tail}"
  end

  task :run do
    cmd = bench_cmd
    $stderr.puts cmd
    exec(cmd)
  end

  task :summary do
    cmd = bench_cmd
    cmd << " | "
    cmd << alf_cmd("summarize -- category -- min 'min{ total }' max 'max{ total }' stddev 'stddev{ total }'")
    $stderr.puts cmd
    exec(cmd)
  end

  task :rank do
    cmd = bench_cmd
    cmd << " | "
    cmd << alf_cmd("rank -- total desc -- position")
    cmd << " | "
    cmd << alf_cmd("project -- position category alf parsing compiling translating printing total")
    cmd << " | "
    cmd << alf_cmd("restrict -- 'position < 10'")
    $stderr.puts cmd
    exec(cmd)
  end

end
task :bench => :"bench:run"