FactoryBot.define do
  factory :user_address do

    sequence(:nickname) { |n| "Nickname #{n}" }

    sequence(:address)  { |n| "Address #{n}" }
    sequence(:city)     { |n| "City #{n}" }
    sequence(:state)    { |n| "State #{n}" }
    sequence(:zip)      { |n| "Zip #{n}" }

    default { false }
    active  { true }

    user { nil }
  end
end
