require 'spec_helper'

describe "Basepack I18n" do
  let(:grid) {Grid::Localization.new}

  it 'localizes Grid column headers' do
    I18n.locale = :es
    columns = grid.final_columns.map(&:text)

    columns.should == %w|Id Autor Ejemplares|
  end
end
