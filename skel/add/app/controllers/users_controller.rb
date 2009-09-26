class UsersController < ApplicationController
  before_filter :require_user, :only => [:show, :edit, :update]

  # HTTP verb and relative path
  #   GET /user/new
  #   GET /user/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # HTTP verb and relative path
  #   POST /user
  #   POST /user.xml
  def create
    update_protected_attrs_from_params(:user, :login) do |p|
      @user = User.new(p)
    end
    @user.active = true

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(user_url) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # HTTP verb and relative path
  #   GET /user/1
  #   GET /user/1.xml
  def show
    @user = current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # HTTP verb and relative path
  #   GET /user/1/edit
  def edit
    @user = current_user
  end

  # HTTP verb and relative path
  #   PUT /user/1
  #   PUT /user/1.xml
  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(user_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
end
