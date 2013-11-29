require 'spec_helper'

feature "Window persistence", js: true do
  it "stores window position and dimentions over a page reload" do
    run_mocha_spec 'window_persistence_set', component: WindowComponentLoader
    run_mocha_spec 'window_persistence_assert', component: WindowComponentLoader
  end
end
