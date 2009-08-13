# Template for apps created by devctm

UNNEEDED_FILES = %w(README public/index.html public/favicon.ico
                    public/robots.txt).freeze

run "rm #{UNNEEDED_FILES.join(' ')}"

git :init

run 'cp config/database.yml config/database.yml.example'


# Set up .gitignores we care about
file 'log/.gitignore', <<-EOF
*.log
EOF

file 'doc/.gitignore', <<-EOF
api
app
EOF

file '.gitignore', <<-EOF
config/database.yml
tmp
coverage
EOF

# Make it so all other empty directories have a .gitignore in them.  This can
# actually put .gitignore files in subdirectories that are already ignored, but
# the spurious .gitignore won't cause any trouble.

run %{find . -type d \\( -name .git -prune -o -empty -print0 \\) | xargs -0 -I yyy touch yyy/.gitignore}

# plugins that aren't available as gems

plugin 'exception_notifier', 
  :git => 'git://github.com/rails/exception_notification.git', :submodule => true

plugin 'redhillonrails_core',
  :git => 'git://github.com/harukizaemon/redhillonrails_core.git', :submodule => true

plugin 'foreign_key_migrations',
  :git => 'git://github.com/harukizaemon/foreign_key_migrations.git', :submodule => true

# Live validations looks like fun, but let's get things working without them,
# first.  BTW, see <http://github.com/ffmike/BigOldRailsTemplate/tree/master>
# for a bunch of useful stuff associated with live validations.

# plugin 'live_validations',
#   :git => 'git://github.com/augustl/live-validations.git'

gem 'rspec', :lib => false
gem 'rspec-rails', :lib => false
gem 'rubyist-aasm', :lib => false
gem 'authlogic'
gem 'tzinfo'
gem 'uuidtools'
gem 'mbleigh-seed-fu'
gem 'unboxed-be_valid_asset'

git :submodule => 'init'
 
rake 'gems:install', :sudo => true
 
generate 'rspec'
generate 'cucumber'

generate('rspec_scaffold', 'user',
         'login:string',
         'crypted_password:string',
         'password_salt:string',
         'persistence_token:string',
         'email:string',
         'login_count:integer',
         'failed_login_count:integer',
         'last_request_at:datetime',
         'current_login_at:datetime',
         'last_login_at:datetime',
         'current_login_ip:string',
         'last_login_ip:string')

# TODO: get rid of hard-coded foo and instead figure out the name of the
        rails app

run 'sudo -u postgres createuser -s foo'

rake 'db:create'
rake 'db:migrate'

# download 'http://livevalidation.com/javascripts/src/1.3/livevalidation_prototype.compressed.js', 'public/javascripts/livevalidation.js'


git :add => '.'
git :commit => '-a -m"Initial devctm_template commit."'


# TODO: set up roles: make sure that there's an admin role and that there's
#       a single root account that has super user passwords, but that the root
#       password is not stored in the git repository.  Probably want to do the
#       same for the db user.
