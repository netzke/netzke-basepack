require 'spec_helper'
feature Netzke::Basepack::Form do
  it 'creates a record', js: true do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')

    run_mocha_spec 'form/create', component: Form::Create

    Book.count.should == 1

    book = Book.first
    book.title.should == 'Damian'
    book.author.should == hesse
  end

  it 'edits a record', js: true do
    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda')
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    book = FactoryGirl.create(:book, author: castaneda)

    run_mocha_spec 'form/edit', component: Form::Edit

    Book.first.author.should == hesse
  end

  it 'resets association', js: true do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    book = FactoryGirl.create(:book, author: hesse)

    run_mocha_spec 'form/reset_association', component: Form::Edit

    Book.first.author.should be_nil
  end

  it 'shows validations errors', js: true do
    run_mocha_spec 'form/validations', component: Form::Create
    Book.first.title.should == 'Brave new world'
  end

  it 'sets date and datetime', js: true do
    run_mocha_spec 'form/datetime', component: Form::Create
    Book.first.published_on.should == '2005-01-23'.to_date
    Book.first.last_read_at.to_s.should == '2005-01-23 11:12:13 UTC'
  end
end
