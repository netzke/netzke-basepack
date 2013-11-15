FactoryGirl.define do
  factory :author do
    first_name 'Carlos'
    last_name 'Castaneda'

    factory :castaneda do
      first_name 'Carlos'
      last_name 'Castaneda'
    end

    factory :fowles do
      first_name 'John'
      last_name 'Fowles'
    end
  end

  factory :book do
    title 'A Book'
  end

  factory :role do
    name 'user'

    factory :admin_role do
      name 'admin'
    end
  end

  factory :user do

  end
end
