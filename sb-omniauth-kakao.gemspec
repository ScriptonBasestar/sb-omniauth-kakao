# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sb-omniauth-kakao/version"

Gem::Specification.new do |spec|
  spec.name        = "sb-omniauth-kakao"
  spec.version     = Omniauth::Kakao::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ["archmagece"]
  spec.email       = ["archmagece@userspec.noreply.github.com"]

  spec.homepage    = "https://github.com/ScriptonBasestar/sb-omniauth-kakao"
  spec.summary     = %q{OmniAuth strategy for Kakao}
  spec.description = %q{OmniAuth strategy for Kakao(http://developerspec.kakao.com/)}
  spec.license     = "MIT"

  spec.rubyforge_project = "sb-omniauth-kakao"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'omniauth', '~> 2.1'
  spec.add_dependency 'omniauth-oauth2', '~> 1.7'

  spec.add_development_dependency 'bundler', '~> 2.6'
  spec.add_development_dependency 'rake', '~> 13.3'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'fakeweb', '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 5.25'
end
