$:.push File.expand_path('../lib', __FILE__)
require 'omniauth/gorgias/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-gorgias-oauth2'
  spec.version       = OmniAuth::Gorgias::VERSION
  spec.authors       = ['Joshua Azemoh', 'Fera Commerce Inc.']
  spec.email         = ['joshua@fera.ai', 'dev@feracommerce.com']

  spec.summary       = 'Gorgias OAuth2 strategy for OmniAuth'
  spec.homepage      = 'https://github.com/feracommerce/omniauth-gorgias-oauth2'
  spec.license       = 'MIT'

  spec.files                 = `git ls-files`.split("\n")
  spec.executables           = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths         = ['lib']

  spec.add_runtime_dependency 'omniauth-oauth2', '~> 1.5'

  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.9', '>= 3.9.0'
end
