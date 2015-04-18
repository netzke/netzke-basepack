require 'spec_helper'
describe Netzke::Basepack::Grid do
  let(:grid) {Grid::Filters.new}

  before do
    nabokov = FactoryGirl.create(:author, first_name: 'Vladimir', last_name: 'Nabokov', year: 1899)
    FactoryGirl.create(:book, author: nabokov, title: "Lolita", exemplars: 5, digitized: false, notes: 'To read', last_read_at: "2010-12-23")

    castaneda = FactoryGirl.create(:author, first_name: 'Carlos', last_name: 'Castaneda', year: 1925)
    FactoryGirl.create(:book, author: castaneda, title: "Journey to Ixtlan", exemplars: 10, digitized: true, notes: 'A must-read', last_read_at: "2011-04-25")

    allen = FactoryGirl.create(:author, first_name: 'David', last_name: 'Allen', year: 1945)
    FactoryGirl.create(:book, author: allen, title: "Getting Things Done", exemplars: 3, digitized: true, notes: 'Productivity', last_read_at: "2011-04-26")
  end

  it 'filters by text' do
    res = grid.read filters: [{"type" => 'string', "field" => 'notes', "value" => 'read'}]
    res[:total].should == 2
  end

  it 'filters by associated record text' do
    res = grid.read filters: [{"type" => 'string', "field" => "author__first_name", "value" => "d"}]
    res[:total].should == 2

    res = grid.read filters: [{"type" => 'string', "field" => "author__first_name", "value" => "carl"}]
    res[:total].should == 1
  end

  it 'filters by associated record integer' do
    res = grid.read filters: [{"type" => 'integer', "field" => "author__year", "comparison" => "eq", "value" => 1899}]
    res[:total].should == 1

    res = grid.read filters: [{"type" => 'integer', "field" => "author__year", "comparison" => "gt", "value" => 1900}]
    res[:total].should == 2
  end

  it 'filters by datetime' do
    res = grid.read filters: [{"type"=>"date", "comparison"=>"eq", "value"=>"04/25/2011", "field"=>"last_read_at"}]
    res[:total].should == 1

    res = grid.read filters: [{"type"=>"date", "comparison"=>"gt", "value"=>"04/25/2011", "field"=>"last_read_at"}]
    res[:total].should == 1

    res = grid.read filters: [{"type"=>"date", "comparison"=>"lt", "value"=>"12/24/2010", "field"=>"last_read_at"}]
    res[:total].should == 1

    res = grid.read filters: [{"type"=>"date", "comparison"=>"gt", "value"=>"12/23/2010", "field"=>"last_read_at"}]
    res[:total].should == 2

    res = grid.read filters: [{"type"=>"date", "comparison"=>"lt", "value"=>"04/26/2011", "field"=>"last_read_at"}, {"type"=>"date", "comparison"=>"gt", "value"=>"12/23/2010", "field"=>"last_read_at"}]
    res[:total].should == 1
  end

  it 'filters by integer' do
    res = grid.read filters: [{"type"=>"integer", "comparison"=>"gt", "value"=>"6", "field"=>"exemplars"}]
    res[:total].should == 1

    res = grid.read filters: [{"type"=>"integer", "comparison"=>"eq", "value"=>"5", "field"=>"exemplars"}]
    res[:total].should == 1

    res = grid.read filters: [{"type"=>"integer", "comparison"=>"eq", "value"=>"6", "field"=>"exemplars"}]
    res[:total].should == 0
  end

  it 'filters by custom filter column' do
    res = grid.read filters: [{"type"=>"string", "value"=>"read", "field"=>"title_or_notes"}]
    res[:total].should == 2

    res = grid.read filters: [{"type"=>"string", "value"=>"o", "field"=>"title_or_notes"}]
    res[:total].should == 3

    res = grid.read filters: [{"type"=>"string", "value"=>"ro", "field"=>"title_or_notes"}]
    res[:total].should == 1

    res = grid.read filters: [{"type"=>"string", "value"=>"ix", "field"=>"title_or_notes"}]
    res[:total].should == 1
  end
end
