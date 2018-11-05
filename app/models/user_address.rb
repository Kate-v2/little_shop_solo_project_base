
class UserAddress < ApplicationRecord

  validates_presence_of :address, :city, :state, :zip, :nickname

  # How do I test this ?
  validates :user_id, uniqueness: {scope: [:nickname]}

  belongs_to :user
  has_many   :orders

end
