#require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
gem 'gem_version', '>= 0.0.1'
require 'gem_version'
#require 'rake/contrib/sshpublisher'

spec = Gem::Specification.new do |s|
  s.name = 'enumerated_state'
  s.version = GemVersion.next_version
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.description = 'Implement state patterns for your enumerated_attributes'
  s.summary = 'ASPIUM (Another State Pattern Implementation Using Mixology)'

  s.add_dependency('enumerated_attribute', '>= 0.2.10')
  s.add_dependency('mixology', '>= 0.2.0')
  s.add_dependency('meta_programming', '>= 0.2.1')
  
  exclude_folders = '' # 'spec/rails/{doc,lib,log,nbproject,tmp,vendor,test}'
  exclude_files = [] # FileList['**/*.log'] + FileList[exclude_folders+'/**/*'] + FileList[exclude_folders]
  s.files = FileList['{lib,spec}/**/*'] + %w(init.rb LICENSE Rakefile README.rdoc .gitignore) - exclude_files
  s.require_path = 'lib'
  s.has_rdoc = true
  s.test_files = Dir['spec/*_spec.rb']
  
  s.author = 'Jeff Patmon'
  s.email = 'jpatmon@gmail.com'
  s.homepage = 'http://github.com/jeffp/enumerated_state/tree/master'
end
 
require 'spec/version'
require 'spec/rake/spectask'

desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.libs << 'lib' << 'spec'
  t.rcov = false
  t.spec_opts = ['--options', 'spec/spec.opts']
  #t.rcov_dir = 'coverage'
  #t.rcov_opts = ['--exclude', "kernel,load-diff-lcs\.rb,instance_exec\.rb,lib/spec.rb,lib/spec/runner.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,\.autotest,#{ENV['GEM_HOME']}"]
end

desc "Generate documentation for the #{spec.name} gem."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = spec.name
  #rdoc.template = '../rdoc_template.rb'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc', 'LICENSE', 'lib/**/*.rb')
end

desc 'Generate a gemspec file.'
task :gemspec do
  File.open("#{spec.name}.gemspec", 'w') do |f|
    f.write spec.to_ruby
  end
  GemVersion.increment_version
  GemVersion.commit_and_push
end
 
Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = RUBY_PLATFORM =~ /mswin/ ? false : true
  p.need_zip = true
end

Dir['tasks/**/*.rake'].each {|rake| load rake}
