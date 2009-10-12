require 'spec_helper'

describe "/admin/users/new.html.erb" do
  include Admin::UsersHelper

  before(:each) do
    assigns[:user] = stub_model(User,
      :new_record? => true,
      :login => "value for login",
      :email => "value for email",
      :password => "value for password",
      :password_confirmation => "value for password",
      :active => false
    )
  end

  it "renders new user form" do
    render :layout => true

    response.should have_tag("form[action=?][method=post]", admin_users_path) do
      with_tag("input#user_login[name=?]", "user[login]")
      with_tag("input#user_email[name=?]", "user[email]")
      with_tag("input#user_password[name=?]", "user[password]")
      with_tag("input#user_password_confirmation[name=?]", "user[password_confirmation]")
      with_tag("input#user_active[name=?]", "user[active]")
    end

    response.should be_valid_xhtml
  end
end
