require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_sessions/new" do
  before(:each) do
    assigns[:user_session] = stub_model(User,
      :new_record? => true,
      :login => "value for login",
      :remember_me => true
    )
  end

  it "renders the login form" do
    render :layout => true

    response.should have_tag("form[action=?][method=post]", user_session_path) do
      with_tag("input#user_login[name=?]", "user[login]")
      with_tag('input#user_password[name=?]', "user[password]")
      with_tag('input#user_remember_me[name=?]', "user[remember_me]")
    end

    response.should be_valid_xhtml
  end
end
