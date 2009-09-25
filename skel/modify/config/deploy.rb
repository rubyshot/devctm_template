default_run_options[:pty] = true

set :application, "APPNAME"
set :repository,  "git@github.com:ctm/APPNAME.git"

set :scm, :git
set :user, 'APPNAME'

role :web, "APPNAME.devctm.com"
role :app, "APPNAME.devctm.com"
role :db,  "APPNAME.devctm.com", :primary => true
# role :db,  "your slave db-server here"

ssh_options[:forward_agent] = true
set :branch, 'master'
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

namespace :deploy do
   task :start do
   end

   task :stop do
   end

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end

  # database.yml is never in the source repository, but the one from the
  # previous release should still be current

  task :after_update_code do
    run "cp -p \"#{current_path}/config/database.yml\" \"#{release_path}/config/\""
  end
end
