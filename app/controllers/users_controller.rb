class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(show new create)
  before_action :load_user, only: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy 
  
  def show
    @user = User.find_by id: params[:id]
    @microposts = @user.microposts.page(params[:page]).per Settings.paging
  end 
    flash[:danger] = "User not found!"
    redirect_to root_path


  def index
      @users = User.page(params[:page]).per Settings.per_page
  end

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      flash[:danger] = t "user.new.danger"
      render :new
    end
  end  
  
  def update
    @user = User.find_by id: params[:id]
    if @user.update_attributes user_params
      flash[:success] = t "user.update"
      redirect_to @user
    else
      flash.now[:danger] = t "user.update_fail"
      render :edit
    end
  end

  def edit
    @user = User.find_by id: params[:id]
  end

  def following
    @title = "Following"
    @user = User.find_by id: params[:id]
    @users = @user.following.page params[:page]
    render "show_follow"
  end
  
  def followers
    @title = "Followers"
    @user = User.find_by id: params[:id]
    @users = @user.followers.page params[:page]
    render "show_follow"
  end
  
  def destroy
    if @user.destroy
      flash[:success] = t "user.delete"
    else
      flash[:danger] = t "user.delete_fail"
    end
    redirect_to users_path
  end

  private
  
  def user_params
    params.require:(user).permit :name, :email, :password, :password_confirmation
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t "user.error.login"
      redirect_to login_url
    end
  end

  def load_user
    @user  = User.find_by id: params[:id]
    return if @user.present?

    flash[:warning] = t "user.new.absent"
    redirect_to root_path
  end

  def correct_user
    redirect_to root_path unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?  
  end
end
