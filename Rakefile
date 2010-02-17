#!/usr/bin/env ruby

require "rake"
require "spec/rake/spectask"

def spec
  spec = Gem::Specification.new do |s|
    require File.dirname(__FILE__) + "/lib/version"
    s.name = "poc-roulette"
    s.version = PocRoulette::Version.to_s
    s.summary = %q{A simple engine for testing algorithms on Casino Roulettes}
    s.description = %q{A simple engine for testing algorithms on Casino Roulettes}
    s.author = %q{Marcelo Manzan}
    s.email = %q{manzan@gmail.com}
    s.homepage = %q{http://github.com/redoc}
    s.has_rdoc = false
    s.files = PKG_FILES

    # Dependencies
    s.add_dependency "activesupport", ">= 2.3.2"
  end
end

Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = FileList["spec/**/*_spec.rb"]
end

desc "Run all specs with RCov"
Spec::Rake::SpecTask.new("spec:rcov") do |t|
  t.spec_files = FileList["spec/**/**_spec.rb"]
  t.rcov = true
  t.rcov_opts = ["--exclude", "spec,Library/*,gems/*"]
end

task :default => :spec

