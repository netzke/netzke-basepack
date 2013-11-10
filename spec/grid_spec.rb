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
end
