require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/show.html.erb" do
  include UsersHelper
  before(:each) do
    assigns[:user] = @user = stub_model(User,
      :login => "value for login",
      :email => "value for email",
      :login_count => 1,
      :failed_login_count => 2,
      :last_request_at => DateTime.parse('20090826140158'),
      :current_login_at => DateTime.parse('20090826140157'),
      :last_login_at => DateTime.parse('20090825140156'),
      :current_login_ip => "value for current_login_ip",
      :last_login_ip => "value for last_login_ip"
    )
    Time.zone = 'UTC'
  end

  it "renders attributes in <p>" do
    render :layout => true

    response.should have_text(/value\ for\ login/)
    response.should have_text(/value\ for\ email/)
    response.should have_text(/1/)
    response.should have_text(/2/)
    response.should have_text(/14:01:58/)
    response.should have_text(/14:01:57/)
    response.should have_text(/14:01:56/)
    response.should have_text(/value\ for\ current_login_ip/)
    response.should have_text(/value\ for\ last_login_ip/)
    response.should be_valid_xhtml
  end
end
