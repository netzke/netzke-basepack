Factory.define :role do |f|
  f.name  "reader"
end

Factory.define :user do |f|
  f.first_name "Peter"
  f.last_name "Pan"
  f.association :role
end

Factory.define :book do |f|
  f.title "Journey to Ixtlan"
end

Factory.define :author do |f|
  f.first_name "Carlos"
  f.last_name "Castaneda"
end

Factory.define :address do |f|
  f.street "Revelation Avenue"
  f.city "Lost Children"
  f.postcode "1234"
end

Factory.define :book_with_custom_primary_key do |f|
  f.title "Book you will write"
end
