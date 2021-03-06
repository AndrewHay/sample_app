class UsersController < ApplicationController
  before_filter :signed_in_user,    
                only: [:index, :edit, :update, :delete, :following, :followers] # sessions_helper.rb
  before_filter :unsigned_in_user,  only: [:create, :new]
  before_filter :correct_user,      only: [:edit, :update]
  before_filter :admin_user,        only: :destroy
  
  def show
    @user = User.find(params[:id])
    # TODO: when the session is closed, but the cookie is still set, /users does not render header properly
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def destroy
    user = User.find(params[:id])
    unless current_user?(user)
      user.destroy
      flash[:success] = "User destroyed."
    else
      flash[:success] = "Cannot destroy yourself!"
    end
    redirect_to users_url
    # 
    # User.find(params[:id]).destroy
    # flash[:success] = "User destroyed."
    
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private
    
    def unsigned_in_user
      if signed_in?
        redirect_to root_path, notice: "Please log out to create a new account."
      end
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
