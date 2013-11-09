hesse = FactoryGirl.create :author, first_name: 'Herman', last_name: 'Hesse'
castaneda = FactoryGirl.create :author, first_name: 'Carlos', last_name: 'Castaneda'
fowles = FactoryGirl.create :author, first_name: 'John', last_name: 'Fowles'

FactoryGirl.create :book, title: 'Journey', author: castaneda, exemplars: 1
FactoryGirl.create :book, title: 'Damian', author: hesse, exemplars: 3
FactoryGirl.create :book, title: 'Magus', author: fowles, exemplars: 2
FactoryGirl.create :book, title: 'Foo', exemplars: 4
