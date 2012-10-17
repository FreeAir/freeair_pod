require 'bundler/capistrano'
 # require 'debot'
set :application, "pod.freeair.io"

set :domain, application
set :environment, "production"
set :branch, "master"
set :deploy_to, "/path/to/apps/pod.freeair.io"

role :app, domain
role :web, domain
role :db, domain, :primary => true

default_run_options[:pty] = true

default_run_options[:shell] = 'bash'

set :repository, "git@github.com:FreeAir/freeair_pod.git"
set :deploy_via, :remote_cache

# If you aren't using Subversion to manage your source code, specify
# your SCM below:

set :stage, "production"
set :scm, :git
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, :forward_agent => true

set :user, "debot"
set :keep_releases, 3


namespace :deploy do

  desc "trust rvmrc"
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end

  desc "Sync the public/assets directory."
  task :upload do
    system "rsync -vr --exclude='.DS_Store' /path/to/freeair/podcasts #{user}@#{application}:/path/to/freeair"
  end

  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -s  /path/to/freeair/podcasts #{release_path}/public/audio"
  end

  desc "Fake migrate (overriding it)"
  task :migrate do
  end
end

namespace :unicorn do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "service unicorn_#{domain} #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end

after 'deploy:setup','deploy:mk_assets_dir', 'deploy:assets'
after 'deploy:update_code', 'deploy:symlink_shared'
