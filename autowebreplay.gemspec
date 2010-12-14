# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "autowebreplay/version"

Gem::Specification.new do |s|
  s.name        = 'autowebreplay'
  s.version     = Autowebreplay::Version::STRING
  s.date = Time.now.strftime('%Y-%m-%d')
  s.authors     = ['Brett Gibson']
  s.email       = ['brettdgibson@gmail.com']
  s.homepage    = ''
  s.summary     = 'automatic playback of web requests for testing'
  s.description = 'automatic playback of web requests for testing'
  s.licenses = 'MIT'
  
  s.add_dependency('webmock', '>=1.6.1')
  s.add_development_dependency('bundler', '>= 0')
  
  s.files = %w(LICENSE.txt README.rdoc Rakefile)
  s.files += Dir.glob('lib/**/*')
  s.files += Dir.glob('test/**/*')
  
  s.test_files = Dir.glob('test/**/*')
  
  s.require_paths = ['lib']
end
