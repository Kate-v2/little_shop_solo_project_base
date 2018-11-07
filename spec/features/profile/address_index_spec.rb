require "rails_helper"
require "feature_helper"


describe 'user sees all addresses' do
  include FeatureHelper

  before(:each) do
    @user = create(:user)
    @address1 = create(:user_address, user: @user, default: true)
    @address2 = create(:user_address, user: @user, default: false)
    @address3 = create(:user_address, user: @user, default: false)
    @address4 = create(:user_address, user: @user, default: false, active: false )

    @url = profile_user_addresses_path(user_id: @user)
  end

  describe 'Viewers' do
    it 'visitor cannot view page' do
      visit @url
      expect(page).to have_content("The page you're looking for could not be found")
    end
    it 'Admin cannot view page' do
      admin = create(:user, role: 2)
      login(admin)
      visit @url
      expect(page).to have_content("The page you're looking for could not be found")
    end
    it 'Merchant cannot view page' do
      merch = create(:user, role: 1)
      login(merch)
      visit @url
      expect(page).to have_content("The page you're looking for could not be found")
    end
    it 'Purchaser can view page' do
      login(@user)
      visit @url
      expect(page).to have_current_path(@url)
    end
  end

  describe 'User' do

    before(:each) do
      login(@user)
      visit @url
      @cards = page.all('.address')
      @card = @cards.first
    end

    describe 'Address includes:' do
      it 'nickname' do
        expect(@card).to have_content(@address1.nickname)
      end
      it 'address' do
        expect(@card).to have_content(@address1.address)
      end
      it 'city' do
        expect(@card).to have_content(@address1.city)
      end
      it 'state' do
        expect(@card).to have_content(@address1.state)
      end
      it 'zip' do
        expect(@card).to have_content(@address1.zip)
      end
      it 'default (if default)' do
        expect(@card).to have_content("Default")
      end
      it 'nothing (if not default)' do
        card = @cards.last
        expect(card).to_not have_content("Default")
      end
      it 'active / inactive' do
        expect(@card).to have_content("Active")
        card = @cards.last
        expect(card).to have_content("Inactive")
      end
    end

    describe 'buttons / options' do

      it 'enable' do
        expect(@card).to     have_button("Disable")
        expect(@card).to_not have_button("Enable")
      end
      it 'disable' do
        card = @cards.last
        expect(card).to_not have_button("Disable")
        expect(card).to     have_button("Enable")
      end
      it 'make default' do
        card = @cards.last
        expect(@card).to_not have_button("Make Default")
        expect(card).to      have_button("Make Default")
      end

    end

    describe 'Address Collection' do

      it 'default is first' do
        card = @card[1]
        expect(@card).to     have_content("Default")
        expect( card).to_not have_content("Default")
      end
      it 'default is only listed once' do
        cards = page.all("#address-#{@address1.id}")
        expect(cards.count).to eq(1)
      end
      it 'all enabled and disabled are present' do
        expect(@address4.active).to eq(false)
        card = page.find("#address-#{@address4.id}")
        expect(card).to have_content("Inactive")
      end
    end

    describe 'linking changes' do

      it 'can enable' do
        card = @cards.last
        card.click_button("Enable")
        expect(page).to have_current_path(@url)
        card = page.all('.address').last
        expect(card).to have_content("Active")
      end
      it 'can disable' do
        card = @cards[1]
        card.click_button("Disable")
        expect(page).to have_current_path(@url)
        card = page.all('.address')[1]
        expect(card).to have_content("Inactive")
      end
      it 'can make default' do
        desired = page.find("#address-#{@address2.id}")
        desired.click_button("Make Default")
        expect(page).to have_current_path(@url)

        first = page.all('.address').first
        expect(first).to     have_content(@address2.address)
        expect(first).to_not have_button("Make Default")
        expect(first).to     have_content("Default")

        previous = page.find("#address-#{@address1.id}")
        expect(previous).to have_content(@address1.address)
        expect(previous).to have_button("Make Default")
      end

      it 'can edit' do
        @card.click_button("Edit")
        url = edit_profile_user_address_path(@address1)
        expect(page).to have_current_path(url)


      end



    end

  end




end
