require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Admin::UsersController do
  describe "route generation" do
    it "maps #new" do
      route_for(:controller => "users", :action => "new").should == "/user/new"
    end

    it "maps #show" do
      route_for(:controller => "users", :action => "show").should == "/user"
    end

    it "maps #edit" do
      route_for(:controller => "users", :action => "edit").should == "/user/edit"
    end

    it "maps #create" do
      route_for(:controller => "users", :action => "create").should == {:path => "/user", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "users", :action => "update").should == {:path =>"/user", :method => :put}
    end
  end

  describe "route recognition" do
    it "generates params for #new" do
      params_from(:get, "/user/new").should == {:controller => "users", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/user").should == {:controller => "users", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/user").should == {:controller => "users", :action => "show"}
    end

    it "generates params for #edit" do
      params_from(:get, "/user/edit").should == {:controller => "users", :action => "edit"}
    end

    it "generates params for #update" do
      params_from(:put, "/user").should == {:controller => "users", :action => "update"}
    end
  end
end
