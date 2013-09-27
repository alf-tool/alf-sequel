source 'http://rubygems.org'

group :runtime do
  # gem "alf-core", path: "../alf-core"
  # gem "alf-sql", path: "../alf-sql"

  gem "alf-core", git: "git://github.com/alf-tool/alf-core.git", branch: :compilable
  gem "alf-sql",  git: "git://github.com/alf-tool/alf-sql.git"

  gem "sequel", "~> 3.48"
end

group :test do
  gem "rake", "~> 10.1"
  gem "rspec", "~> 2.14"
  gem "sqlite3", "~> 1.3",      :platforms => ['mri', 'rbx']
  gem "jdbc-sqlite3", "~> 3.7", :platforms => ['jruby']
  gem "pg"
  gem "alf-shell", :git => "git://github.com/alf-tool/alf-shell.git"
  gem "alf-test",  :git => "git://github.com/alf-tool/alf-test.git"
end

group :development do
  gem "rake", "~> 10.1"
  gem "rspec", "~> 2.14"
end
