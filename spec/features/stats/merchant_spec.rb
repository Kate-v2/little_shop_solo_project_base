require 'rails_helper'

RSpec.describe 'Merchant Stats' do
  context 'as a merchant, viewing my dashboard' do
    before(:each) do
      @merchant_1 = create(:merchant)
      @merchant_2 = create(:merchant)

      @user_1 = create(:user)
      @address_1 = create(:user_address, user: @user_1, default: true, city: 'Denver', state: "CO")

      @user_2 = create(:user)
      @address_2 = create(:user_address, user: @user_2, default: true, city: 'Los Angeles', state: "CA")

      @user_3 = create(:user)
      @address_3 = create(:user_address, user: @user_3, default: true, city: 'Tampa', state: "FL")

      @user_4 = create(:user)
      @address_4 = create(:user_address, user: @user_4, default: true, city: 'NYC', state: "NY")

      @item_1 = create(:item, user: @merchant_1)

      # Denver/Colorado is 2nd place
      @order_1 = create(:completed_order, user: @user_1, user_address: @address_1)
      create(:fulfilled_order_item, order: @order_1, item: @item_1)
      @order_2 = create(:completed_order, user: @user_1, user_address: @address_1)
      create(:fulfilled_order_item, order: @order_2, item: @item_1)
      @order_3 = create(:completed_order, user: @user_1, user_address: @address_1)
      create(:fulfilled_order_item, order: @order_3, item: @item_1)
      # Los Angeles, California is 1st place
      @order_4 = create(:completed_order, user: @user_2, user_address: @address_2)
      create(:fulfilled_order_item, order: @order_4, item: @item_1)
      @order_5 = create(:completed_order, user: @user_2, user_address: @address_2)
      create(:fulfilled_order_item, order: @order_5, item: @item_1)
      @order_6 = create(:completed_order, user: @user_2, user_address: @address_2)
      create(:fulfilled_order_item, order: @order_6, item: @item_1)
      @order_7 = create(:completed_order, user: @user_2, user_address: @address_2)
      create(:fulfilled_order_item, order: @order_7, item: @item_1)
      # Sorry Tampa, Florida
      @order_8 = create(:completed_order, user: @user_3, user_address: @address_3)
      create(:fulfilled_order_item, order: @order_8, item: @item_1)
      # NYC, NY is 3rd place
      @order_9 = create(:completed_order, user: @user_4, user_address: @address_4)
      create(:fulfilled_order_item, order: @order_9, item: @item_1)
      @order_A = create(:completed_order, user: @user_4, user_address: @address_4)
      create(:fulfilled_order_item, order: @order_A, item: @item_1)
    end
    it 'shows total items I have sold and as a percentage of inventory' do

      skip("Join Table in User model")


      merchant_1, merchant_2 = create_list(:merchant, 2)
      total_units = 100
      sold_units = 20
      item_1 = create(:item, inventory: total_units, user: merchant_1)
      item_2 = create(:item, user: merchant_2)

      order = create(:completed_order, user: @user_1, user_address: @address_1 )
      oi_1 = create(:fulfilled_order_item, quantity: sold_units, order: order, item: item_1)
      oi_2 = create(:fulfilled_order_item, order: order, item: item_2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant_1)

      visit dashboard_path

      within '#stats' do
        within '#inv-stats' do
          expect(page).to have_content("Total Items Sold: #{sold_units}")
          expect(page).to have_content("Represents #{(sold_units/total_units*100).round(2)}% of Inventory")
        end
      end
    end
    it 'shows top 3 states where I have shipped items' do

      skip("Join Table in User model")


      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      visit dashboard_path

      within '#stats' do
        within '#stats-top-states' do
          expect(page).to have_content("Top 3 States:\n#{@user_2.state} #{@user_1.state} #{@user_4.state}")
        end
      end
    end
    it 'shows top 3 cities where I have shipped items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)


      skip("Join Table in User model")


      visit dashboard_path

      within '#stats' do
        within '#stats-top-cities' do
          expect(page).to have_content("Top 3 Cities:\n#{@user_2.city} #{@user_1.city} #{@user_4.city}")
        end
      end
    end
    it 'shows most active user buying my items' do

      skip("Join Table in User model")



      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)

      # user 2 is winning at first
      visit dashboard_path
      within '#stats' do
        active_user = @merchant_1.top_active_user
        expect(page).to have_content("Most Active Buying User: #{@user_2.name}, #{active_user.order_count} orders")
      end
      # but if we disable this user, confirm user 1 is next best
      @user_2.update(active: false)

      visit dashboard_path
      within '#stats' do
        active_user = @merchant_1.top_active_user
        expect(page).to have_content("Most Active Buying User: #{@user_1.name}, #{active_user.order_count} orders")
      end
    end
    it 'shows largest order by quantity of my items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)


      skip("Join Table in User model")


      visit dashboard_path
      within '#stats' do
        within '#stats-biggest-order' do
          expect(page).to have_content("Order ##{@order_A.id}, worth $#{@order_A.total}")
          expect(page).to have_content("It had #{@merchant_1.biggest_order.item_count} items of yours in the order")
        end
      end
    end
    it 'shows top 3 spending users who bought my items' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)


      skip("Join Table in User model")


      visit dashboard_path
      within '#stats' do
        within '#stats-top-buyers' do
          buyers = @merchant_1.top_buyers(3)
          expect(page).to have_content("#{buyers[0].name}, $#{buyers[0].total_spent}")
          expect(page).to have_content("#{buyers[1].name}, $#{buyers[1].total_spent}")
          expect(page).to have_content("#{buyers[2].name}, $#{buyers[2].total_spent}")
        end
      end
    end

  end


  describe 'Merchant To Do list' do

    before(:each) do
      @merchant = create(:user, role: 1)
      @item1 = create(:item, user: @merchant, image: nil)
      @item2 = create(:item, user: @merchant, image: nil)
      @item3 = create(:item, user: @merchant)

      user = create(:user)
      address = create(:user_address, user: user)

      @order1 = create(:order, user_address: address, user: user)
      @order2 = create(:order, user_address: address, user: user)
      @order3 = create(:order, user_address: address, user: user)

      @oitem1 = create(:order_item, item: @item1, order: @order1)
      @oitem2 = create(:order_item, item: @item2, order: @order1, fulfilled: true)
      @oitem3 = create(:order_item, item: @item3, order: @order2)
      @oitem4 = create(:order_item, item: @item3, order: @order3)

      login(@merchant)
      visit dashboard_path
    end

    it 'displays all items that need images' do
      list = page.find('.missing-images')
      expect(list).to     have_content(@item1.name)
      expect(list).to     have_content(@item2.name)
      expect(list).to_not have_content(@item3.name)
    end

    it 'items that need images are links' do
      item = page.find('.missing-images')
      item.click_on("#{@item1.name}")
      path = edit_merchant_item_path(merchant_id: @merchant.id, id: @item1.id)
      expect(page).to have_current_path(path)
    end

    it 'displays orders that need to be fulfilled' do
      section = page.find('.pending_orders')
      # oitem = section.find("#pending-#{@oitem1.}")
      expect(section).to      have_content(@oitem1.item.name)
      expect(section).to_not have_content(@oitem2.item.name)
      expect(section).to     have_content(@oitem3.item.name)
    end

    it 'links to fulfilling orders' do


    end





  end

end


def login(user)
  visit logout_path
  visit login_path
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Log in"
end
