# -*- encoding: utf-8 -*-

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "apns/version"

Gem::Specification.new do |s|
  s.name = "apns"
  s.version = APNS::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Pozdena", "Thomas Kollbach", "Samujjal Purkayastha", "Albert Wang"]
  s.autorequire = "apns"
  s.date = "2015-03-13"
  s.description = <<DESC
Simple Apple push notification service gem.
It supports the 3rd wire format (command 2) with support for content-availible (Newsstand), expiration dates and delivery priority (background pushes)
DESC

  s.email = ["jpoz@jpoz.net", "thomas@kollba.ch", "samujjal@cellabus.com", "albert@cellabus.com"]
  s.extra_rdoc_files = ["MIT-LICENSE"]
  s.files = ["MIT-LICENSE", "README.textile", "Rakefile", "lib/apns", "lib/apns/core.rb", "lib/apns/notification.rb", "lib/apns.rb"]
  s.homepage = "http://github.com/cellabus/apns"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.3.5"
  s.summary = "Simple Apple push notification service gem"

  s.add_development_dependency "rspec"
  s.add_development_dependency "codeclimate-test-reporter"
end
