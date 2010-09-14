# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# TODO: replace with faker
Role.create([
  {:name => "writer"},
  {:name => "reader"}
])

User.create([
  {:first_name => "Mark", :last_name => "Twain", :role => Role.find_by_name("writer")},
  {:first_name => "Carlos", :last_name => "Castaneda", :role => Role.find_by_name("writer")},
  {:first_name => "Sergei", :last_name => "Kozlov", :role => Role.find_by_name("reader")},
  {:first_name => "Paul", :last_name => "Schyska", :role => Role.find_by_name("reader")}
])