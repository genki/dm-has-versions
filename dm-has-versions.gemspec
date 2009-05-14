# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-has-versions}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Genki Takiuchi"]
  s.date = %q{2009-05-15}
  s.description = %q{Merb plugin that provides version control for DataMapper models.}
  s.email = %q{genki@s21g.com}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/dm-has-versions", "lib/dm-has-versions/has", "lib/dm-has-versions/has/versions.rb", "lib/dm-has-versions/merbtasks.rb", "lib/dm-has-versions.rb", "spec/dm-has-versions_spec.rb", "spec/fixture", "spec/fixture/app", "spec/fixture/app/models", "spec/fixture/app/models/comment.rb", "spec/fixture/app/models/story.rb", "spec/spec.opts", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://blog.s21g.com/genki}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Merb plugin that provides version control for DataMapper models.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<merb>, [">= 1.0.7.1"])
    else
      s.add_dependency(%q<merb>, [">= 1.0.7.1"])
    end
  else
    s.add_dependency(%q<merb>, [">= 1.0.7.1"])
  end
end
