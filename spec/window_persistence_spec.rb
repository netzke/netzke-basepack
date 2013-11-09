require 'spec_helper'

feature "Window persistence", js: true do
  it "stores window position and dimentions over a page reload" do
    run_mocha_spec 'window_persistence_set', component: WindowComponentLoader
    # visit "/components/WindowComponentLoader?spec=extra__window_persistence_set"
    # wait_for_javascript
    # assert_mocha_results

    run_mocha_spec 'window_persistence_assert', component: WindowComponentLoader
    # visit "/components/WindowComponentLoader?spec=extra__window_persistence_assert"
    # wait_for_javascript
    # assert_mocha_results
  end
end
