require 'spec_helper'

describe "Basepack I18n" do
  let(:grid) {Grid::Localization.new}

  it 'localizes Grid column headers' do
    I18n.locale = :es
    columns = grid.non_meta_columns.map(&:text)
    expect(columns).to eql %w|Id Autor Ejemplares|
    I18n.locale = :en # important
  end

  describe "Netzke::Grid localizations" do
    let(:grid) { Netzke::Grid::Base.new }

    it 'maintains correct locale YML for grid actions' do
      add_i18n = {
        nl: 'Toevoegen',
        en: 'Add',
        es: 'Agregar',
        de: 'Hinzufügen',
        ru: 'Добавить',
        uk: 'Додати'
      }

      add_i18n.each_pair do |locale,expected|
        I18n.locale = locale
        res = Netzke::Grid::Base.new(model: Book).actions[:add][:text]
        expect(res).to eql expected
      end
    end

    it 'maintains correct locale YML for form actions' do
      add_i18n = {
        de: 'Anwenden',
        en: 'Apply',
        es: 'Aplicar',
        nl: 'Toepassen',
        ru: 'Применить',
        uk: 'Застосувати'
      }

      add_i18n.each_pair do |locale,expected|
        I18n.locale = locale
        res = Netzke::Form::Base.new(model: Book).actions[:apply][:text]
        expect(res).to eql expected
      end
    end

    it 'maintains correct locale YML for tree actions' do
      add_i18n = {
        de: 'Hinzufügen',
        en: 'Add',
        es: 'Agregar',
        nl: 'Toevoegen',
        ru: 'Добавить',
        uk: 'Додати'
      }

      add_i18n.each_pair do |locale,expected|
        I18n.locale = locale
        res = Netzke::Tree::Base.new(model: Book).actions[:add][:text]
        expect(res).to eql expected
      end
    end
  end
end
