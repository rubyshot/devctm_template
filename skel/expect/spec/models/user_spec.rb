require 'spec_helper'

describe Admin::User do
  before(:each) do
    @valid_attributes = {
      :login => "value for login",
      :email => "value for email",
      :crypted_password => "value for crypted_password",
      :password_salt => "value for password_salt",
      :persistence_token => "value for persistence_token",
      :single_access_token => "value for single_access_token",
      :perishable_token => "value for perishable_token",
      :login_count => 1,
      :failed_login_count => 1,
      :last_request_at => Time.now,
      :current_login_at => Time.now,
      :last_login_at => Time.now,
      :current_login_ip => "value for current_login_ip",
      :last_login_ip => "value for last_login_ip",
      :active => false,
      :time_zone => "value for time_zone"
    }
  end

  it "should create a new instance given valid attributes" do
    Admin::User.create!(@valid_attributes)
  end
end
