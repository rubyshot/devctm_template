require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index.html.erb" do
  include Admin::UsersHelper

  before(:each) do
    assigns[:users] = [
      stub_model(User,
        :login => "value for login",
        :email => "value for email",
        :login_count => 1,
        :failed_login_count => 1,
        :current_login_ip => "value for current_login_ip",
        :last_login_ip => "value for last_login_ip",
        :active => false
      ),
      stub_model(User,
        :login => "value for login",
        :email => "value for email",
        :login_count => 1,
        :failed_login_count => 1,
        :current_login_ip => "value for current_login_ip",
        :last_login_ip => "value for last_login_ip",
        :active => false
      )
    ]
    assigns[:users].should_receive(:total_pages).and_return(1)
  end

  it "renders a list of users" do
    render :layout => true

    response.should have_tag("tr>td", "value for login".to_s, 2)
    response.should have_tag("tr>td", "value for email".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for current_login_ip".to_s, 2)
    response.should have_tag("tr>td", "value for last_login_ip".to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should be_valid_xhtml
  end
end
