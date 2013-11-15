require 'spec_helper'
feature Netzke::Basepack::ActionColumn do
  it 'allows implementing destroy action', js: true do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    FactoryGirl.create :book, title: 'Damian', author: hesse
    run_mocha_spec 'grid/action_column'
  end
end
