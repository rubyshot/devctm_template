require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/edit.html.erb" do
  include UsersHelper

  before(:each) do
    assigns[:user] = @user = stub_model(User,
      :new_record? => false,
      :login => "value for login",
      :email => "value for email"
    )
  end

  it "renders the edit user form" do
    render :layout => true

    response.should have_tag("form[action=#{user_path(:secure => true)}][method=post]") do
      with_tag('input#user_email[name=?]', "user[email]")
      with_tag('input#user_password[name=?]', "user[password]")
      with_tag('input#user_password_confirmation[name=?]', "user[password_confirmation]")
    end
    response.should be_valid_xhtml
  end
end
