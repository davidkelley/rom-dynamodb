FactoryBot.define do
  factory :user, class: Hash do
    id { SecureRandom.uuid }

    name { Faker::Name.name }

    sequence(:created_at) { |n| Time.now.to_i + n * 10 }

    initialize_with { attributes }
  end
end
