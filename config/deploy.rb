# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'multiply_me_api'
set :repo_url, 'git@github.com:frasermince/MultiplyMeApi.git'
set :scm, :git
set :pty, true

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :secrets do
  desc "SCP transfer secret configuration to the shared folder"
  task :deploy do
    on roles(:app) do
      upload! StringIO.new(File.read("config/secrets.yml")), "#{shared_path}/secrets.yml"
      execute "ln -sf #{shared_path}/secrets.yml #{release_path}/config/secrets.yml"
    end
  end
end

before :deploy, 'unicorn:stop'
after :deploy, 'deploy:finished'

namespace :unicorn do
  desc "Start unicorn"
  task :start do
    on roles(:app) do
      #execute "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D"
      #execute "ps aux | grep unicorn_rails | head -n 1 | awk '{print $2}' > #{deploy_to}/shared/tmp/pids/unicorn.pid"
      execute 'sudo service unicorn start'
    end
  end

  desc "Stop unicorn"
  task :stop do
    on roles(:app) do
      #execute "kill -s QUIT `cat  #{deploy_to}/shared/tmp/pids/unicorn.pid`"
      execute 'sudo service unicorn stop'
    end
  end
  task :restart do
    on roles(:app) do
      execute 'sudo service unicorn restart'
    end
  end
end

namespace :upload do
  desc 'Upload public directory'
  task :public do
    on roles(:app) do
      execute "rm -r #{shared_path}/public"
      execute "rm -r #{current_path}/public"
      upload! 'public', "#{shared_path}/public", recursive: true
      execute "ln -sf #{shared_path}/public #{release_path}/public"
    end
  end

  desc "Database config"
  task :database do
    on roles(:app) do
      upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
      execute "ln -sf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
  end
end

namespace :deploy do

  desc "Bundle"
  task :binstub do
    on roles(:app) do
      execute "cd /var/www/MultiplyMeApi/current; bundle --binstubs"
    end
  end

  desc 'after deploy'
  task :finished do
    invoke 'secrets:deploy'
    invoke 'deploy:binstub'
    invoke 'unicorn:start'
  end


  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
