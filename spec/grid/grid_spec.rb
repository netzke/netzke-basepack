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

  it 'shows proper error when model prevents deleting a record', js: true do
    FactoryGirl.create :book, title: 'Untouchable'
    run_mocha_spec 'grid/untouchable_record', component: 'BookGrid'
  end

  it 'loads data properly being 2 instances in tabs', js: true do
    FactoryGirl.create :book
    FactoryGirl.create :book
    run_mocha_spec 'grid/in_tabs'
  end

  it 'takes custom columns renderers into account', js: true do
    castaneda = FactoryGirl.create :author, first_name: 'Carlos', last_name: 'Castaneda'
    FactoryGirl.create :book, title: 'Journey to Ixtlan', author: castaneda
    run_mocha_spec 'grid/custom_renderers'
  end

  it 'keeps row selection after grid reload', js: true do
    4.times do
      FactoryGirl.create :book
    end
    run_mocha_spec 'grid/selection', component: 'Grid::Crud'
  end

  it 'shows number of pages in the paging toolbar', js: true do
    FactoryGirl.create :book, title: 'One'
    FactoryGirl.create :book, title: 'Two'
    FactoryGirl.create :book, title: 'Three'
    FactoryGirl.create :book, title: 'Four'
    run_mocha_spec 'grid/pagination'
  end

  it 'shows inline data on initial load', js: true do
    FactoryGirl.create :book, title: 'One'
    FactoryGirl.create :book, title: 'Two'
    run_mocha_spec 'grid/inline_data'
  end
end
