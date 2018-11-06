
class UserAddressesController < ApplicationController

  def index
    id = params[:format].to_i
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
      if params[:active]
        @address.active = params[:active]
        can_save(@address, :enabled, :disabled)
      end
      if params[:default] == true
        previous = UserAddress.find_by(default: true )
        previous.default = false
        can_save(previous, :previous, :other)
        @address.default = true
        can_save(@address, :default, :other)
      end

      redirect_to profile_user_addresses_path
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
      flash[:notice] = flashes[success]
      true
    else
      flash[:notice] = flashes[fail]
      false
    end
  end

  def flashes
    {
      previous: "#{@previous.address.titleize} is no longer your default address.",
      default:  "#{@address.address.titleize } is now your default address.",
      enabled:  "#{@address.address.titleize } has been enabled.",
      disabled: "#{@address.address.titleize } has been disabled.",
      success:  "#{@address.address.titleize } has been created.",
      failure:  "New address failed to create.",
      other:    "Something went wrong."
    }
  end


end
