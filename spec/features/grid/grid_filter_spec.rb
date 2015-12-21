require 'spec_helper'
feature Netzke::Grid::Base, js: true do
  before do
    nabokov = FactoryGirl.create(:author, first_name: 'Vladimir', last_name: 'Nabokov')
    FactoryGirl.create(:book, author: nabokov, title: "Lolita", exemplars: 5, digitized: false, notes: 'To read', last_read_at: "2010-12-23", price: 1.1234)

    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda')
    FactoryGirl.create(:book, author: castaneda, title: "Journey to Ixtlan", exemplars: 10, digitized: true, notes: 'A must-read', last_read_at: "2011-04-25", price: 1.2345)

    allen = FactoryGirl.create(:author, first_name: 'David', last_name: 'Allen')
    FactoryGirl.create(:book, author: allen, title: "Getting Things Done", exemplars: 3, digitized: true, notes: 'Productivity', last_read_at: "2011-04-26", price: 1.3456)
  end

  it 'makes use of various filters' do
    run_mocha_spec 'grid/filters'
  end
end
