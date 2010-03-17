# Template for apps created by devctm.  See README.rdoc for more info.

begin
  require File.dirname(template) + '/lib/tools'
rescue MissingSourceFile => e
  STDERR.puts "Please use an absolute path name with the -m command line option."
  STDERR.puts "You used a relative path name, which makes it impossible to find helper files."
  exit 1
end
extend Devctm::Template::Tools

db_password = ask_for_password('database password')
admin_password = ask_for_password('admin password')

git :init

run 'cp config/database.yml config/database.yml.example'

tell_git_about_empty_directories

# plugins that aren't available as gems

run "gem sources -a http://gems.github.com"

plugin 'exception_notifier',
  :git => 'git://github.com/rails/exception_notification.git',
  :submodule => true

plugin 'foreigner',
  :git => 'git://github.com/ctm/foreigner.git',
  :submodule => true

# Use seed-fu as a plugin because if we use the gem version, rake db:seed
# doesn't work (known bug).

plugin 'seed_fu',
  :git => 'git://github.com/mbleigh/seed-fu.git',
  :submodule => true

plugin 'validation_reflection',
  :git => 'git://github.com/redinger/validation_reflection.git',
  :submodule => true

# We use bcurren ssl_requirement, because quantipay ssl_requirement
# causes links on an https page to be http links which then just get
# redirected to https, whereas bcurren doesn't use full paths when the
# protocol doesn't need to change.  This is especially obvious with scaffolded
# destroy links, like on a scaffolded index page.  W/quantipay ssl_requirment
# the index page would properly be brought up as an ssl page, but the link
# to the destroy would be http:.  So the temp-form-submit would do the submit
# as http:, which would then be redirected to https but would then fail.  No
# such problem with bcurren.

plugin 'ssl_requirement',
  :git => 'git://github.com/bcurren/ssl_requirement.git',
  :submodule => true

# Live validations looks like fun, but let's get things working without them,
# first.  BTW, see <http://github.com/ffmike/BigOldRailsTemplate/tree/master>
# for a bunch of useful stuff associated with live validations.

# plugin 'live_validations',
#   :git => 'git://github.com/augustl/live-validations.git'

gem 'pg'
gem 'rspec', :lib => false
gem 'rspec-rails', :lib => false
gem 'rubyist-aasm', :lib => 'aasm'
gem 'authlogic'
gem 'tzinfo'
gem 'uuidtools'
gem 'unboxed-be_valid_asset', :lib => false
gem 'bluecloth', :version => '>= 2.0.0'
gem 'justinfrench-formtastic', :lib => 'formtastic'
gem 'mislav-will_paginate', :lib => 'will_paginate'

git :submodule => 'init'

run "sudo -u postgres createuser -s #{app_name}"

gsub_file 'config/database.yml', /^( *password:) *$/, "\\1 #{db_password}"
run "echo \"alter user #{app_name} encrypted password '\"'#{db_password}'\"';\" | sudo -u postgres psql"
 
rake 'gems:install', :sudo => true
 
generate 'formtastic_stylesheets'
generate 'rspec'
generate 'cucumber'

# We're going to use rspec_scaffold to create the admin access to the user.
# rspec_scaffold won't actually do exactly what we want, but it will be
# close enough that it makes an OK starting point.

columns = %w(login:string
             email:string
             crypted_password:string
             password_salt:string
             persistence_token:string
             single_access_token:string
             perishable_token:string
             login_count:integer
             failed_login_count:integer
             last_request_at:datetime
             current_login_at:datetime
             last_login_at:datetime
             current_login_ip:string
             last_login_ip:string
             active:boolean
             time_zone:string)

generate 'model', '--git', 'User', *columns
generate 'rspec_scaffold', '--git', '--skip-migration', 'Admin::User', *columns

File.rename 'spec/models/admin/user_spec.rb', 'spec/models/user_spec.rb'
Dir.delete 'spec/models/admin'

generate 'session', '--git', 'user_session'
generate 'rspec_controller', '--git', 'user_sessions', 'new', 'create', 'destroy'

# download 'http://livevalidation.com/javascripts/src/1.3/livevalidation_prototype.compressed.js', 'public/javascripts/livevalidation.js'

rake 'db:create'
rake 'db:sessions:create'

append_file 'config/initializers/session_store.rb', "ActionController::Base.session_store = :active_record_store\n"
for environment in %w(test development)
  # The blank line after these comment linesis needed because, at
  # least in Rails 2.3.3, the final line of
  # config/environments/{test,development}.rb does not have an end of
  # line character.
  append_file "config/environments/#{environment}.rb", <<-'EOF'

config.after_initialize do
  SslRequirement.disable_ssl_check = true
end
  EOF
end

gsub_file 'config/environment.rb',  /config.time_zone = 'UTC'/, "config.time_zone = 'Mountain Time (US & Canada)'"

run 'capify .'

fix_skel_migrations
update_app_from_skel

rake 'db:migrate'

File.rename 'db/fixtures/0000_users.rb.placeholder', 'db/fixtures/0000_users.rb'
gsub_file 'db/fixtures/0000_users.rb', /ADMIN_PASSWORD_PLACEHOLDER/, admin_password

gsub_file 'config/deploy.rb', /APPNAME/, app_name

rake 'db:seed_fu'

git :add => '.'
git :commit => '-a -m"Initial devctm_template commit."'

log "Database password: #{db_password.inspect}"
log "Admin password is #{admin_password.inspect}"
