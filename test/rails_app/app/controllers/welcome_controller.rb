class WelcomeController < ApplicationController
  def index
    render :text => "This is a test app built into netzke-basepack"
  end
end
