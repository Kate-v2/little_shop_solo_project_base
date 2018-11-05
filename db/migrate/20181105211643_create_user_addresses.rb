class CreateUserAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :user_addresses do |t|
      t.string     :nickname
      t.string     :address
      t.string     :city
      t.string     :state
      t.integer    :zip
      t.boolean    :default, default: false
      t.boolean    :active,  default: true

      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
