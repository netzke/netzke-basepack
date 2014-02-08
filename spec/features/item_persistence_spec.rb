require 'spec_helper'

feature "Item persistence", js: true do
  it "stores item position and dimentions over a page reload" do
    run_mocha_spec 'item_persistence_set', component: ItemPersistence
    run_mocha_spec 'item_persistence_assert', component: ItemPersistence
  end
end
