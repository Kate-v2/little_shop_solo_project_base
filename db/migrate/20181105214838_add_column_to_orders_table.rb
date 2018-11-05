class AddColumnToOrdersTable < ActiveRecord::Migration[5.1]
  def change
    add_reference :orders, :user_address, foreign_key: true
  end
end
