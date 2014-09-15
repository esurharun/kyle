Gem::Specification.new do |gem|
  gem.name        = 'kyle'
  gem.version     = '0.0.5'
  gem.date        = '2014-09-17'

  gem.summary     = 'Kyle'
  gem.description = 'A password manager for paranoids.'
  gem.authors     = ['Harun Esur', 'Isaac Seymour']
  gem.email       = 'harun.esur@sceptive.com'
  gem.homepage    = 'http://sceptive.com'
  gem.license     = 'MIT'
  gem.requirements << 'Ruby should be compiled with openssl support.'

  gem.executables << 'kyle'

  gem.files = `git ls-files`.split("\n")

  gem.add_runtime_dependency 'highline', '~> 1.6', '>= 1.6.20'

  gem.add_development_dependency 'rubocop', '~> 0.26'
  gem.add_development_dependency 'rspec', '~> 3.0.0'
end
