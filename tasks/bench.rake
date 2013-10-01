namespace :bench do

  task :run do
    cmd = "ALF_TEST_ENV=postgres bundle exec ruby -Ilib bench/bench_all.rb"
    $stderr.puts cmd
    exec(cmd)
  end

  task :summary do
    cmd = "ALF_TEST_ENV=postgres bundle exec ruby -Ilib bench/bench_all.rb"
    cmd << " | "
    cmd << "alf --ff=%.6f --input-reader=rash summarize -- category -- min 'min{ total }' max 'max{ total }' stddev 'stddev{ total }'"
    $stderr.puts cmd
    exec(cmd)
  end

  task :rank do
    cmd = "ALF_TEST_ENV=postgres bundle exec ruby -Ilib bench/bench_all.rb"
    cmd << " | "
    cmd << "alf --input-reader=rash rank -- total desc -- position"
    cmd << " | "
    cmd << "alf --input-reader=rash project -- position category query parsing compiling translating printing total"
    cmd << " | "
    cmd << "alf --ff=%.6f --input-reader=rash restrict -- 'position < 10'"
    $stderr.puts cmd
    exec(cmd)
  end

end
task :bench => :"bench:run"