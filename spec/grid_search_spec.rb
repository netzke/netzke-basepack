require 'spec_helper'

describe "Grid search" do
  let(:grid) {BookGrid.new}

  before do
    FactoryGirl.create :book, title: 'Zero', published_on: '2003-12-21', digitized: true, last_read_at: '2006-12-21T08:00:00'
    FactoryGirl.create :book, title: 'One', published_on: '2005-12-21', digitized: true, last_read_at: '2008-12-21T08:00:00'
    FactoryGirl.create :book, title: 'Two', published_on: '2006-12-21', digitized: false, last_read_at: '2008-12-21T14:00:00'
    FactoryGirl.create :book, title: 'Three', published_on: '2007-12-21', digitized: true, last_read_at: '2010-12-21T13:00:00'
  end

  it 'searches by title' do
    res = grid.read query: [[{attr: 'title', operator: 'contains', value: 'One'}]]
    res[:total].should == 1

    res = grid.read query: [[{attr: 'title', operator: 'contains', value: 'T'}]]
    res[:total].should == 2
  end

  it 'searches by published_on date' do
    res = grid.read query: [[{attr: 'published_on', operator: 'eq', value: '2005-12-21'}]]
    res[:total].should == 1

    res = grid.read query: [[{attr: 'published_on', operator: 'gt', value: '2005-12-21'}]]
    res[:total].should == 2

    res = grid.read query: [[{attr: 'published_on', operator: 'gt', value: '2005-12-20'}]]
    res[:total].should == 3

    res = grid.read query: [[{attr: 'published_on', operator: 'lt', value: '2006-12-22'}]]
    res[:total].should == 3

    res = grid.read query: [[{attr: 'published_on', operator: 'gteq', value: '2005-12-21'}]]
    res[:total].should == 3
  end

  it 'searches by digitized boolean' do
    res = grid.read query: [[{attr: 'digitized', operator: 'eq', value: true}]]
    res[:total].should == 3

    res = grid.read query: [[{attr: 'digitized', operator: 'eq', value: false}]]
    res[:total].should == 1
  end

  it 'searches by last_read_at' do
    res = grid.read query: [[{attr: 'last_read_at', operator: 'eq', value: '2008-12-21'}]]
    res[:total].should == 2

    res = grid.read query: [[{attr: 'last_read_at', operator: 'eq', value: '2010-12-21'}]]
    res[:total].should == 1

    res = grid.read query: [[{attr: 'last_read_at', operator: 'eq', value: '2006-12-21'}]]
    res[:total].should == 1

    res = grid.read query: [[{attr: 'last_read_at', operator: 'gt', value: '2008-12-21'}]]
    res[:total].should == 1

    res = grid.read query: [[{attr: 'last_read_at', operator: 'gteq', value: '2008-12-21'}]]
    res[:total].should == 3

    res = grid.read query: [[{attr: 'last_read_at', operator: 'lt', value: '2010-12-21'}]]
    res[:total].should == 3

    res = grid.read query: [[{attr: 'last_read_at', operator: 'lteq', value: '2010-12-21'}]]
    res[:total].should == 4
  end
end
