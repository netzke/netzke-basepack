require 'spec_helper'
feature Netzke::Grid::Base do
  before do
    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda', prize_count: 10)
    FactoryGirl.create(:book, author: castaneda, title: "The Teachings of Don Juan", exemplars: 10, digitized: true, published_on: "1968-01-01", last_read_at: "2010-01-25", price: 1.1)
    FactoryGirl.create(:book, author: castaneda, title: "Journey to Ixtlan", exemplars: 10, digitized: true, published_on: "1970-01-01", notes: 'A must-read', last_read_at: "2011-04-25", price: 1.2345)
  end

  it 'uses various getters', js: true do
    run_mocha_spec 'grid/getters'
  end
end
