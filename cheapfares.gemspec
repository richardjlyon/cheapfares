# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','cheapfares','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'cheapfares'
  s.version = Cheapfares::VERSION
  s.author = 'Richard Lyon'
  s.email = 'richardlyon@fastmail.com'
  s.homepage = 'http://www.richardlyon.net'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Command line utility for retrieving and reporting cheap rail fares'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','cheapfares.rdoc']
  s.rdoc_options << '--title' << 'cheapfares' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'cheapfares'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.14.0')
end
