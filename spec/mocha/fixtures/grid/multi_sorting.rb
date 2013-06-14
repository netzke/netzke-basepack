a = FactoryGirl.create :author, last_name: 'A'
b = FactoryGirl.create :author, last_name: 'B'
c = FactoryGirl.create :author, last_name: 'C'

FactoryGirl.create :book, exemplars: 2, title: 'B', author: b
FactoryGirl.create :book, exemplars: 2, title: 'A', author: a
FactoryGirl.create :book, exemplars: 1, title: 'B', author: b
FactoryGirl.create :book, exemplars: 2, title: 'B', author: c
FactoryGirl.create :book, exemplars: 2, title: 'B', author: a
