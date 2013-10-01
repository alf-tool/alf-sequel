$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require "alf/sequel/version"
$version = Alf::Sequel::Version.to_s

Gem::Specification.new do |s|
  s.name = "alf-sequel"
  s.version = $version
  s.summary = "A sequel adapter for alf"
  s.description = "This project implements an Alf adapter on top of the awesome sequel toolkit."
  s.homepage = "http://github.com/blambeau/alf-sequel"
  s.authors = ["Bernard Lambeau"]
  s.email  = ["blambeau at gmail.com"]
  s.require_paths = ['lib']
  here = File.expand_path(File.dirname(__FILE__))
  s.files = File.readlines(File.join(here, 'Manifest.txt')).
                 inject([]){|files, pattern| files + Dir[File.join(here, pattern.strip)]}.
                 collect{|x| x[(1+here.size)..-1]}
  s.add_development_dependency("alf-test", "~> 0.15.0")
  s.add_development_dependency("alf-shell", "~> 0.15.0")
  s.add_development_dependency("rake", "~> 10.1")
  s.add_development_dependency("rspec", "~> 2.14")
  s.add_dependency("alf-core", "~> 0.15.0")
  s.add_dependency("alf-sql", "~> 0.15.0")
  s.add_dependency("sequel", "~> 3.48")
end
