describe "Window component", ->
  it "loads window and sets its size", (done) ->
    click button "Load window"
    wait ->
      expect(activeWindow().getWidth()).to.eql 300
      expect(activeWindow().getHeight()).to.eql 200
      expect(activeWindow().getPosition()).to.eql [100, 80]

      activeWindow().setSize(150, 100)
      activeWindow().setPosition(50, 40)
      wait ->
        done()
