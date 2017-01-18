FactoryGirl.define do
  factory :log, class: Hash do
    transient do
      sequence_step 100
    end

    host { Faker::Internet.ip_v6_address }

    message { "[#{Time.now.to_s}] [#{[200,404,500,422,400,201].sample}] #{Faker::Internet.url}" }

    sequence(:logged_at) { |n| Time.now.to_i + (n * sequence_step) }

    initialize_with { attributes }
  end
end
