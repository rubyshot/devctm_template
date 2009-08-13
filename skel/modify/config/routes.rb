ActionController::Routing::Routes.draw do |map|
  map.resource :user_session, :only => [:new, :create, :destroy]

  map.resource :user, :only => [:new, :create, :show, :edit, :update]

  map.namespace 'admin' do |admin|
    admin.resources :users
  end

  if RAILS_ENV == 'test'
    # Make routes for actions whose sole purpose is to test various
    # methods that are in ApplicationController for use by other controllers

    map.with_options :controller => 'application_controller_test' do |test|
      for helper in %w(require_user require_admin require_no_user
                                                      save_notify_and_redirect)
        test.send helper, "/#{helper}", :action => "#{helper}_test"
      end
    end
  end
end
