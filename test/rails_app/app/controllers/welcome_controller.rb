class WelcomeController < ApplicationController
  def index
    render :text => "This is a test app build into netzke-basepack"
  end
end