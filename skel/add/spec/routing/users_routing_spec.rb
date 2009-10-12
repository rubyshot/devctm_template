require 'spec_helper'

describe UsersController do
  describe "routing" do
    it "recognizes and generates #new" do
      { :get => "/user/new" }.should route_to(:controller => "users", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/user" }.should route_to(:controller => "users", :action => "show")
    end

    it "recognizes and generates #edit" do
      { :get => "/user/edit" }.should route_to(:controller => "users", :action => "edit")
    end

    it "recognizes and generates #create" do
      { :post => "/user" }.should route_to(:controller => "users", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/user" }.should route_to(:controller => "users", :action => "update")
    end
  end
end
