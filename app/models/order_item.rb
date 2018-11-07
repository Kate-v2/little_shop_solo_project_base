class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  def subtotal
    s = quantity * price
    # binding.pry
    s
  end


# -------------------------
  def can_be_fulfilled?
    inventory = self.item.inventory
    inventory >= self.quantity
  end

  def pending_items(merchant)
    

  end



end
