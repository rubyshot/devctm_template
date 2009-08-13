require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/show.html.erb" do
  include Admin::UsersHelper
  before(:each) do
    assigns[:user] = @user = stub_model(User,
      :login => "value for login",
      :email => "value for email",
      :login_count => 1,
      :failed_login_count => 1,
      :current_login_ip => "value for current_login_ip",
      :last_login_ip => "value for last_login_ip",
      :active => false
    )
  end

  it "renders attributes in <p>" do
    render :layout => true

    response.should have_text(/value\ for\ login/)
    response.should have_text(/value\ for\ email/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ current_login_ip/)
    response.should have_text(/value\ for\ last_login_ip/)
    response.should have_text(/false/)

    response.should be_valid_xhtml
  end
end
