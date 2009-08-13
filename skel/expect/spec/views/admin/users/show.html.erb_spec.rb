require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin_users/show.html.erb" do
  include Admin::UsersHelper
  before(:each) do
    assigns[:user] = @user = stub_model(Admin::User,
      :login => "value for login",
      :email => "value for email",
      :crypted_password => "value for crypted_password",
      :password_salt => "value for password_salt",
      :persistence_token => "value for persistence_token",
      :single_access_token => "value for single_access_token",
      :perishable_token => "value for perishable_token",
      :login_count => 1,
      :failed_login_count => 1,
      :current_login_ip => "value for current_login_ip",
      :last_login_ip => "value for last_login_ip",
      :active => false,
      :time_zone => "value for time_zone"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ login/)
    response.should have_text(/value\ for\ email/)
    response.should have_text(/value\ for\ crypted_password/)
    response.should have_text(/value\ for\ password_salt/)
    response.should have_text(/value\ for\ persistence_token/)
    response.should have_text(/value\ for\ single_access_token/)
    response.should have_text(/value\ for\ perishable_token/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ current_login_ip/)
    response.should have_text(/value\ for\ last_login_ip/)
    response.should have_text(/false/)
    response.should have_text(/value\ for\ time_zone/)
  end
end
