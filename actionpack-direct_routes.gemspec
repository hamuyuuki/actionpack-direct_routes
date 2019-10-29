$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "actionpack/direct_routes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "actionpack-direct_routes"
  s.version     = ActionPack::DirectRoutes::VERSION
  s.authors     = ["hamuyuuki"]
  s.email       = ["13702378+hamuyuuki@users.noreply.github.com"]
  s.homepage    = "https://github.com/hamuyuuki/actionpack-direct_routes"
  s.summary     = "Backport Direct routes into Rails 4 and Rails 5.0."
  s.description = "`actionpack-direct_routes` backports Direct routes into Rails 4 and Rails 5.0. Rails 5.1 adds Direct routes that you can create custom URL helpers directly."
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "actionpack", "~> 4.2.0"
  s.add_dependency "activesupport", "~> 4.2.0"

  s.add_development_dependency "minitest", "~> 5.1.0"
  s.add_development_dependency "rails", "~> 4.2.0"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "sqlite3", "~> 1.3.0"
end
