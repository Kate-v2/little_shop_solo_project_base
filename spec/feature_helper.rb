
module FeatureHelper

  def login(user)
    visit logout_path
    visit login_path
    fill_in :email,    with: user.email
    fill_in :password, with: user.password
    click_button("Log in")
  end



end
