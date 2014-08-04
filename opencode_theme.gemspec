# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opencode_theme/version'

Gem::Specification.new do |spec|
  spec.name          = "opencode_theme"
  spec.version       = OpencodeTheme::VERSION
  spec.authors       = ["Rafael Takashi Tanaka"]
  spec.email         = ["rtanaka@tray.net.br"]
  spec.description   = %q{nao esquecer de fazer}
  spec.summary       = %q{fazer depois}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.add_dependency('thor', '>= 0.14.4')
  spec.add_dependency('httparty', '~> 0.13.0')
  spec.add_dependency('json', '~> 1.8.0')
  spec.add_dependency('mimemagic')
  spec.add_dependency('filewatcher')
  spec.add_dependency('launchy')

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '>= 5.0.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-debugger'


  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"


  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables  << 'opencode'
  spec.require_paths = ['lib']
end
