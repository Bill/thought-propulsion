namespace 'propel' do
  namespace 'heroku' do

    # usage rake propel:heroku:update_git_submodules 
    desc 'Heroku does not automatically update submodules so we have to do it ourselves'
    task :update_git_submodules do
      puts `git submodule init 2>&1`
      puts `git submodule update 2>&1`
    end
    
  end
end
