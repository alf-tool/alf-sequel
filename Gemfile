source 'http://rubygems.org'

group :runtime do
  # gem "alf-core", :git => "git://github.com/alf-tool/alf-core.git"
  # gem "alf-core", "~> 0.13.0"
  # gem "alf-core", path: "../alf-core"
  gem "alf-core", path: "../alf-core"
  gem "alf-sql", path: "../alf-sql"
  gem "sequel", "~> 3.48"
end

group :test do
  gem "rake", "~> 10.1"
  gem "rspec", "~> 2.14"
  gem "sqlite3", "~> 1.3",      :platforms => ['mri', 'rbx']
  gem "jdbc-sqlite3", "~> 3.7", :platforms => ['jruby']
  gem "alf-test", path: "../alf-test"
  gem "pg"
end

group :development do
  gem "rake", "~> 10.1"
  gem "rspec", "~> 2.14"
end
