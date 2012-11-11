Then /^active window size must be (\d+),(\d+)$/ do |w, h|
  page.driver.browser.execute_script(<<-JS).should == [w.to_i,h.to_i]
    var win = Ext.WindowMgr.getActive();
    return [win.getWidth(), win.getHeight()];
  JS
end

Then /^active window position must be (\d+),(\d+)$/ do |x, y|
  page.driver.browser.execute_script(<<-JS).should == [x.to_i,y.to_i]
    var win = Ext.WindowMgr.getActive();
    return win.getPosition();
  JS
end

When /^I move active window to (\d+),(\d+)$/ do |x, y|
  page.driver.browser.execute_script(<<-JS)
    var win = Ext.WindowMgr.getActive();
    win.setPosition(#{x},#{y});
  JS
end

When /^I resize active window to (\d+),(\d+)$/ do |w, h|
  page.driver.browser.execute_script(<<-JS)
    var win = Ext.WindowMgr.getActive();
    win.setSize(#{w},#{h});
  JS
end
