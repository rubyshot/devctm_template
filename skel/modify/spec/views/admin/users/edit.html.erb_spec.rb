require 'spec_helper'

describe "/admin/users/edit.html.erb" do
  include Admin::UsersHelper

  before(:each) do
    assigns[:user] = @user = stub_model(User,
      :new_record? => false,
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
      :active => false
    )
  end

  it "renders the edit user form" do
    render :layout => true

    response.should have_tag("form[action=#{admin_user_path(@user, :secure => true)}][method=post]") do
      with_tag('input#user_login[name=?]', "user[login]")
      with_tag('input#user_email[name=?]', "user[email]")
      with_tag('input#user_password[name=?]', "user[password]")
      with_tag('input#user_password_confirmation[name=?]', "user[password_confirmation]")
    end
    response.should be_valid_xhtml
  end
end
