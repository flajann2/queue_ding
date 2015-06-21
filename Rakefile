# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'semver'

def s_version
  SemVer.find.format "%M.%m.%p%s"
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "queue_ding"
  gem.homepage = "http://github.com/flajann2/queue_ding"
  gem.license = "MIT"
  gem.summary = %Q{QueueDing is a working alternative to Queue}
  gem.description = %Q{
  This roughly mirrors the functionaly of Queue in allowing you to
  queue messages to one or more threads, and will block if the queue
  is empty, waking up when there is another message available.
  }
  gem.email = "fred.mitchell@gmx.de"
  gem.authors = ["Fred Mitchell"]
  gem.required_ruby_version = '>= 2.0'
  gem.version = s_version

  # Exclusions
  gem.files.exclude 'foo/**/*', 'rdoc/*',
                    '.idea/**/*', '.idea/**/.*', '.yardoc/**/*',
                    'Guardfile'

end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
