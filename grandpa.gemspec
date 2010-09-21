# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "grandpa"
  s.version = '0.0.2'

  s.authors = ["Ari Russo"]
  s.date = Date.today
  s.description = "Grandpa is an MVC framework for Ruby which is built on the Gosu game development library."
  s.summary = "Ruby graphical MVC application framework"
  s.email = ["ari.russo@gmail.com"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = Dir.glob("{lib}/**/*") + %w(README.rdoc)
  s.homepage = %q{http://github.com/arirusso/grandpa}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.specification_version = 3

  s.add_development_dependency("gosu")
end
