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
  {:title => "Journey to Ixtlan", :author => castaneda, exemplars: 2, notes: 'Basic ideas', tags: 'must-read', rating: 1, digitized: false, last_read_at: 2000.hours.ago, published_on: 2.years.ago},
  {:title => "The Tales of Power", :author => castaneda, exemplars: 1, notes: 'Advanced reading', tags: 'mystics', rating: 2, digitized: true, last_read_at: 20.hours.ago, published_on: 5.years.ago},
  {:title => "The Art of Dreaming", :author => castaneda, exemplars: 3, notes: 'Concious dreaming', tags: 'must-read, mystics', rating: 1, digitized: false, last_read_at: 200.hours.ago, published_on: 7.years.ago},
  {:title => "Steppenwolf", :author => hesse, exemplars: 1, notes: 'Suicidal man', tags: 'psychology, must-read', rating: 3, digitized: true, last_read_at: 30.hours.ago, published_on: 5.years.ago},
  {:title => "Demian", :author => hesse, exemplars: 1, notes: 'How a child sees the world', tags: 'must-read', rating: 1, digitized: true, last_read_at: 300.hours.ago, published_on: 3.years.ago},
  {:title => "Narciss and Goldmund", :author => hesse, exemplars: 3, notes: 'Inspiring', tags: 'must-read', rating: 1, digitized: false, last_read_at: 3000.hours.ago, published_on: 8.years.ago}
])
