require 'spec_helper'
feature Netzke::Basepack::Grid do
  before do
    frisch = FactoryGirl.create(:author, first_name: 'Max', last_name: 'Frisch')
    FactoryGirl.create(:book, author: frisch, title: "Biedermann und die Brandstifter", exemplars: 5, digitized: false, notes: 'To read', last_read_at: "2010-12-23")

    durrenmatt = FactoryGirl.create(:author, first_name: 'Friedrich', last_name: 'Dürrenmatt')
    FactoryGirl.create(:book, author: durrenmatt, title: "Die Panne", exemplars: 10, digitized: true, notes: 'A must-read', last_read_at: "2011-04-25")

    adams = FactoryGirl.create(:author, first_name: 'Douglas', last_name: 'Adams')
    FactoryGirl.create(:book, author: adams, title: "The Hitchhiker's Guide to the Galaxy", exemplars: 3, digitized: true, notes: 'The Answer', last_read_at: "2012-04-26")
  end

  it 'makes use of default string filter', js: true do
    run_mocha_spec 'grid/default_string_filter'
  end

  it 'makes use of default date filter', js: true do
    run_mocha_spec 'grid/default_date_filter'
  end
end
