
class UserAddressesController < ApplicationController

  def index
    id = params[:user_id].to_i
    if current_user && current_user.id == id
      @user = User.find(id) # if current_user.id == id
      addresses  = @user.user_addresses
      @default   = addresses.where(default: true).first    if addresses
      @addresses = addresses.where('id != ?', @default.id) if addresses
    else
      render file: 'errors/not_found', status: 404
    end
  end

  def new
  end

  def create
    # if none or disabled, then make default
    # if save, success
    # else failure
  end

  def edit
  end

  def update
    if current_user
      id = params[:id].to_i
      @address = UserAddress.find(id)
      if !params[:active].nil?
        @address.active = true  if params[:active] == "true"
        @address.active = false if params[:active] == "false"
        can_save(@address, :enabled, :disabled)
      end
      if params[:default] == "true"
        @previous = UserAddress.find_by(default: true )
        @previous.default = false
        can_save(@previous, :previous, :other)
        @address.default = true
        can_save(@address, :default, :other)
      end

      redirect_to profile_user_addresses_path(user_id: current_user)
    else
      render file: 'errors/not_found', status: 404
    end
  end


  private

  def address_params
    params.require(:address).permit(:nickname, :address, :city, :state, :zip)
  end

  def can_save(address, success, fail)
    if address.save
      flash[:notice] = "#{address.address.titleize}" + flashes[success]
      true
    else
      flash[:notice] = "#{address.address.titleize}" + flashes[fail]
      false
    end
  end

  def flashes
    {
      previous: " is no longer your default address.",
      default:  " is now your default address.",

      enabled:  " has been enabled.",
      disabled: " has been disabled.",

      success:  " has been created.",
      failure:  "New address failed to create.",

      other:    "Something went wrong."
    }
  end


end
