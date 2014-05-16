Gem::Specification.new do |s|
  s.name        = 'kyle'
  s.version     = '0.0.1'
  s.date        = '2014-05-17'
  s.summary     = "Kyle"
  s.description = "A password manager for paranoids."
  s.authors     = ["Harun Esur"]
  s.email       = 'harun.esur@sceptive.com'
  s.executables << 'kyle'
  s.files       = ["lib/kyle.rb"]
  s.homepage    =
    'http://sceptive.com'
  s.license       = 'MIT'
  s.add_runtime_dependency 'highline', '~> 1.6', '>= 1.6.20'
  s.requirements << "Ruby should be compiled with openssl support."
end