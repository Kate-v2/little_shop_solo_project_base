FactoryBot.define do
  factory :user_address do
    address { "MyString" }
    city { "MyString" }
    state { "MyString" }
    zip { 1 }
    nickname { "MyString" }
    default { false }
    active { false }
  end
end
