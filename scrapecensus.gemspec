# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "scrapecensus"
  s.license     = "MIT"
  s.authors     = ["PJ Gray"]
  s.email       = "pj@evertrue.com"
  s.homepage    = "http://www.evertrue.com/"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.summary     = "ScrapeCensus"
  s.description = "Scripts for scraping census data"

  s.add_dependency "commander", "~> 4.1.2"
  s.add_dependency "terminal-table", "~> 1.4.5"
  s.add_dependency "term-ansicolor", "~> 1.0.7"
  s.add_dependency "faraday"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
