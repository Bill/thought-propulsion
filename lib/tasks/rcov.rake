if RAILS_ENV == 'development'

  require 'spec/rake/spectask'

  namespace 'propel' do
    desc "Run rcov (coverage analysis) on specs"
    Spec::Rake::SpecTask.new('coverage') do |t|
      t.spec_files = FileList['spec/**/*.rb']
      t.rcov = true
      t.rcov_opts = ['--exclude', 'examples']
    end
  end
  
end # if RAILS_ENV == 'development'