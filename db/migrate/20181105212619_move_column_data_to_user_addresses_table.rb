class MoveColumnDataToUserAddressesTable < ActiveRecord::Migration[5.1]

  def change
    User.find_each do |user|
      user.user_addresses.create(
        :address => user.address,
        :city    => user.city,
        :state   => user.state,
        :zip     => user.zip,
        :user    => user
      )
    end
  end

end
