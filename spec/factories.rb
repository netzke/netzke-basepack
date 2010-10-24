Factory.define :role do |f|
  f.name  "reader"
end

Factory.define :user do |f|
  f.first_name "Peter"
  f.last_name "Pan"
  f.association :role
end