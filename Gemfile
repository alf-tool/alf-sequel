source 'http://rubygems.org'

group :development do
  gem "rake", "~> 10.1"
  gem "rspec", "~> 2.14"
end

group :runtime do
  gem "sequel", "~> 4.2"

  gem "alf-core", path: "../alf-core"
  gem "alf-sql",  path: "../alf-sql"
end

group :test do
  gem "rake", "~> 10.1"
  gem "rspec", "~> 2.14"
  gem "sqlite3", "~> 1.3",      :platforms => ['mri', 'rbx']
  gem "jdbc-sqlite3", "~> 3.7", :platforms => ['jruby']
  gem "pg"
end
