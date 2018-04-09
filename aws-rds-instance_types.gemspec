# -*- encoding: utf-8 -*-

require File.expand_path('../lib/dldinternet/aws/rds/instance_types/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "aws-rds-instance_types"
  gem.version       = DLDInternet::AWS::RDS::Instance_Types::VERSION
  gem.description   =
  gem.summary       = %q{Retrieve an up to date list of valid AWS RDS Instance Types directly from Amazon Web Services official site.}
  gem.license       = 'Apachev2'
  gem.authors       = ['Christo De Lange']
  gem.email         = 'rubygems@dldinternet.com'
  gem.homepage      = 'https://rubygems.org/gems/aws-rds-instance_types'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'

  gem.add_runtime_dependency('thor', ['>= 0.19.1'])
  gem.add_dependency 'awesome_print', '> 0'
  gem.add_dependency 'inifile', '> 0'
  gem.add_dependency 'colorize', '>= 0'
  gem.add_dependency 'dldinternet-mixlib-logging', '>= 0.7.1'
  gem.add_dependency 'aws-ec2-instance_types', '>= 2.0.0'
  gem.add_dependency 'psych'
  gem.add_dependency 'json'
end
