describe "Window component assertion", ->
  it "loads window and sets its size", (done) ->
    click button "Load window"
    wait ->
      expect(activeWindow().getWidth()).to.eql 150
      expect(activeWindow().getHeight()).to.eql 100
      expect(activeWindow().getPosition()).to.eql [50, 40]
      done()
