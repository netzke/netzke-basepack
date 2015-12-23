require 'spec_helper'

describe "Basepack I18n" do
  let(:grid) {Grid::Localization.new}

  it 'localizes Grid column headers' do
    I18n.locale = :es
    columns = grid.non_meta_columns.map(&:text)
    expect(columns).to eql %w|Id Autor Ejemplares|
    I18n.locale = :en # important
  end
end
