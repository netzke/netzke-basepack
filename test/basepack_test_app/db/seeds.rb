# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Role.delete_all
puts "Creating roles..."
Role.create([
  {:name => "writer"},
  {:name => "reader"}
])

User.delete_all
puts "Creating users..."
User.create([
  {:first_name => "Mark", :last_name => "Twain", :role => Role.find_by_name("writer")},
  {:first_name => "Carlos", :last_name => "Castaneda", :role => Role.find_by_name("writer")},
  {:first_name => "Sergei", :last_name => "Kozlov", :role => Role.find_by_name("reader")},
  {:first_name => "Paul", :last_name => "Schyska", :role => Role.find_by_name("reader")}
])

Author.delete_all
puts "Creating authors..."
Author.create([
  {:first_name => "Carlos", :last_name => "Castaneda"},
  {:first_name => "Herman", :last_name => "Hesse"}
])

Book.delete_all

hesse = Author.find_by_last_name("Hesse")
castaneda = Author.find_by_last_name("Castaneda")
puts "Creating books..."
Book.create([
  {:title => "Journey to Ixtlan", :author => castaneda},
  {:title => "The Tales of Power", :author => castaneda},
  {:title => "The Art of Dreaming", :author => castaneda},
  {:title => "Steppenwolf", :author => hesse},
  {:title => "Demian", :author => hesse},
  {:title => "Narciss and Goldmund", :author => hesse}
])