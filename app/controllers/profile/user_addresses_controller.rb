

class UserAddressController < ApplicationController

  def index
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
    # if save, success
    # else failure
  end


  private

  def address_params
    params.require(:address).permit(:nickname, :address, :city, :state, :zip)
  end



end
