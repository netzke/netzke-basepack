FactoryGirl.define do
  factory :role do |f|
    f.name  "reader"
  end

  factory :user do |f|
    f.first_name "Peter"
    f.last_name "Pan"
    f.association :role
  end

  factory :book do |f|
    f.title "Journey to Ixtlan"
  end

  factory :author do |f|
    f.first_name "Carlos"
    f.last_name "Castaneda"
  end

  factory :address do |f|
    f.street "Revelation Avenue"
    f.city "Lost Children"
    f.postcode "1234"
  end

  factory :book_with_custom_primary_key do |f|
    f.title "Book you will write"
  end
end
