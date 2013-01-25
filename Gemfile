source 'http://rubygems.org'

group :runtime do
  gem "alf-core", :git => "git://github.com/alf-tool/alf-core.git"
  #gem "alf-core", :path => "../alf-core"
  gem "sequel", "~> 3.36"
end

group :test do
  gem "rake", "~> 10.0"
  gem "rspec", "~> 2.12"
  gem "sqlite3", "~> 1.3",      :platforms => ['mri', 'rbx']
  gem "jdbc-sqlite3", "~> 3.7", :platforms => ['jruby']
end

group :development do
  gem "rake", "~> 10.0"
  gem "rspec", "~> 2.12"
end
