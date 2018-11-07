
class UserAddressesController < ApplicationController

  def index

    

    # regular index
    # checkout with index
    if permissions
      @user = User.find(@id) # if current_user.id == id
      addresses  = @user.user_addresses
      @default   = addresses.where(default: true).first    if addresses
      @addresses = addresses.where('id != ?', @default.id) if addresses
    else
      not_found
    end
  end

  def new
    if permissions
      @user = current_user
      @address = UserAddress.new
      @form_url = profile_user_addresses_path
      @method = :post
    else
      not_found
    end
  end

  def create
    # if none or disabled, then make default
    # if save, success
    # else failure
    if permissions
      @user = current_user
      @address = UserAddress.new(address_params)
      default = UserAddress.where(user_id: @user.id, default: true )
      @address.default = false if default.count > 0
      @address.default = true  if default.count == 0

      saved = can_save(@address, :success, :failure)
      redirect_to profile_user_addresses_path if saved
      render :new if !saved
    else
      not_found
    end
  end

  def edit
    if permissions
      @user = current_user
      id = params[:id].to_i
      @address = UserAddress.find(id)
      @form_url = profile_user_address_path(address)
      @method = :put
    else
      not_found
    end
  end

  def update
    if permissions
      id = params[:id].to_i
      @address = UserAddress.find(id)
      if !params[:active].nil?
        @address.active = true  if params[:active] == "true"

        if params[:active] == "false"
          @address.active = false
          # if @address.default == true
          #   new_default = UserAddress.where(user_id: current_user.id, active: true).first
          #   new_default.default = true
          #   new_default.save
          # end
        end

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
      not_found
    end
  end


  private

  def address_params
    params.require(:address).permit(:nickname, :address, :city, :state, :zip)
  end

  def format_user_id
    @id = params[:user_id].to_i
  end

  def permissions
    # @id = params[:user_id].to_i
    format_user_id
    current_user && current_user.id == @id
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

  def not_found
    render file: 'errors/not_found', status: 404
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
