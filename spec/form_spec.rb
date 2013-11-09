require 'spec_helper'
feature Netzke::Basepack::Form, js: true do
  it 'creates a record' do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')

    run_mocha_spec 'form/create', component: Form::Crud

    Book.count.should == 1

    book = Book.first
    book.title.should == 'Damian'
    book.author.should == hesse
  end

  it 'edits a record' do
    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda')
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    book = FactoryGirl.create(:book, author: castaneda)

    run_mocha_spec 'form/edit', component: Form::Edit

    Book.first.author.should == hesse
  end
end
