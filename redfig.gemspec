Gem::Specification.new do |s|
  s.name        = 'redfig'
  s.version     = '0.0.0'
  s.date        = '2013-09-20'
  s.summary     = "Redis backed app configuration client"
  s.description = ""
  s.authors     = ["Peter Ellis Jones"]
  s.email       = 'pj@ukoki.com'
  s.files       = ["lib/redfig.rb"]
  s.require_paths = ["lib"]
  s.homepage    = ''
  s.license     = 'MIT'
  s.add_dependency('redis', [">= 0"])
end