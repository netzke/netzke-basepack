require 'spec_helper'
feature Netzke::Form::Base, js: true do
  it 'creates a record', js: true do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')

    run_mocha_spec 'form/create', component: Form::Create

    expect(Book.count).to eql 1

    book = Book.first
    expect(book.title).to eql 'Damian'
    expect(book.author).to eql hesse
  end

  it 'edits a record', js: true do
    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda')
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    book = FactoryGirl.create(:book, author: castaneda)

    run_mocha_spec 'form/edit', component: Form::Edit

    expect(Book.first.author).to eql hesse
  end

  it 'resets association', js: true do
    hesse = FactoryGirl.create(:author, first_name: 'Herman', last_name: 'Hesse')
    book = FactoryGirl.create(:book, author: hesse)

    run_mocha_spec 'form/reset_association', component: Form::Edit

    expect(Book.first.author).to be_nil
  end

  it 'shows validations errors', js: true do
    run_mocha_spec 'form/validations', component: Form::Create
    expect(Book.first.title).to eql 'Brave new world'
  end

  it 'sets date and datetime', js: true do
    run_mocha_spec 'form/datetime', component: Form::Create
    expect(Book.first.published_on).to eql '2005-01-23'.to_date
    expect(Book.first.last_read_at.to_s).to eql '2005-01-23 11:12:13 UTC'
  end

  # This doesn't test actual fil upload, due to that selenium cannot attach_file to Ext JS file upload field, but it at
  # least protects a form with file upload from some errors; file upload has to be tested manually for now :(
  it 'allows uploading attachments via form' do
    run_mocha_spec 'form/file_upload'
    expect(Illustration.last.title).to eql "Picture"
  end
end
