require 'spec_helper'
feature Netzke::Basepack::Grid, js: true do
  before do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda')

    FactoryGirl.create(:book, title: 'Journey to Ixtlan', notes: 'Journey to Ixtlan', author: castaneda)
    FactoryGirl.create(:book, title: 'The Art of Dreaming', notes: 'The Art of Dreaming', author: castaneda)
    FactoryGirl.create(:book, title: 'Way of Warrior', notes: 'Way of Warrior', author: castaneda)
    FactoryGirl.create(:book, title: 'Damian', notes: 'Damian', author: hesse)
  end

  it 'performs search via form' do
    run_mocha_spec 'grid/search'
  end
end
