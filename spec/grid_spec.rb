require 'spec_helper'
feature Netzke::Basepack::Grid do
  it 'performs CRUD operations', js: true do
    FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda')
    run_mocha_spec 'grid/crud'
  end

  it 'creates records with default values', js: true do
    FactoryGirl.create :author, first_name: 'Vladimir', last_name: 'Nabokov'
    run_mocha_spec 'grid/default_values'
  end

  it 'allows setting initial sorting on multiple columns', js: true do
    a = FactoryGirl.create :author, last_name: 'A'
    b = FactoryGirl.create :author, last_name: 'B'
    c = FactoryGirl.create :author, last_name: 'C'

    FactoryGirl.create :book, exemplars: 2, title: 'B', author: b
    FactoryGirl.create :book, exemplars: 2, title: 'A', author: a
    FactoryGirl.create :book, exemplars: 1, title: 'B', author: b
    FactoryGirl.create :book, exemplars: 2, title: 'B', author: c
    FactoryGirl.create :book, exemplars: 2, title: 'B', author: a

    run_mocha_spec 'grid/multisorting'
  end
end
