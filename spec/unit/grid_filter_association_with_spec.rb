require 'spec_helper'
describe Netzke::Grid::Base do
  let(:grid) {Grid::FilterAssociationWith.new}
  let(:columns) { grid.columns }

  before do
    nabokov = FactoryGirl.create(:author, first_name: 'Vladimir', last_name: 'Nabokov', year: 1899)
    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda', year: 1925)
    castaneda = FactoryGirl.create(:author, first_name: 'Maria', last_name: 'Castaneda', year: 1927)
  end

  it 'filters by custom field' do
    result = grid.model_adapter.combo_data(columns[0], '1920')
    expect(result.size).to eq 2

    result = grid.model_adapter.combo_data(columns[0], '1850')
    expect(result.size).to eq 3
  end

  it 'uses getters to display results' do
    result = grid.model_adapter.combo_data(columns[0], '1926')
    expect(result.first.last).to eq 'Maria Castaneda'
  end
end
