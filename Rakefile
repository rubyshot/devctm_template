require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'

require 'lib/tools'
include Devctm::Template::Tools

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

namespace :spec do
  desc "Run all specs with RCov"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,/Library/Ruby,/usr/lib/ruby']
  end
end


desc 'Use RDoc to generate html'
Rake::RDocTask.new('doc') do |rdoc|
  rdoc.rdoc_files.include('**/*.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'list the files that are present in skel/modify but not in skel/expect'
task :check_expect do
  skel_targets('skel', 'modify') do |modify_file, ignored|
    expect_file = modify_file.sub('/modify/', '/expect/')
    puts "#{modify_file}" unless File.file?(expect_file)
  end
end

task :default => :spec
