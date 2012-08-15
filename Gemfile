source 'http://rubygems.org'

group :runtime do
  gem "alf", :git => "git://github.com/alf-tool/alf.git"
  #gem "alf", :path => "../alf"
  gem "sequel", "~> 3.36"
end

group :test do
  gem "rake", "~> 0.9.2"
  gem "rspec", "~> 2.10"
  gem "sqlite3", "~> 1.3",      :platforms => ['mri', 'rbx']
  gem "jdbc-sqlite3", "~> 3.7", :platforms => ['jruby']
end

group :development do
  gem "rake", "~> 0.9.2"
  gem "rspec", "~> 2.10"
end
