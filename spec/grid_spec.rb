require 'spec_helper'
feature Netzke::Basepack::Grid do
  it 'performs CRUD operations', js: true do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda')
    run_mocha_spec 'grid/crud'
  end
end
