require 'spec_helper'
describe Netzke::Grid::Base do
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
    res = grid.read filters: [{"type" => 'string', "property" => 'notes', "value" => 'read'}]
    expect(res[:total]).to eql 2
  end

  it 'filters by associated record text' do
    res = grid.read filters: [{"type" => 'string', "property" => "author__first_name", "value" => "d"}]
    expect(res[:total]).to eql 2

    res = grid.read filters: [{"type" => 'string', "property" => "author__first_name", "value" => "carl"}]
    expect(res[:total]).to eql 1
  end

  it 'filters by associated record integer' do
    res = grid.read filters: [{"type" => 'integer', "property" => "author__year", "value" => 1899, "operator" => "eq"}]
    expect(res[:total]).to eql 1

    res = grid.read filters: [{"type" => 'integer', "operator" => "gt", "property" => "author__year", "value" => 1900}]
    expect(res[:total]).to eql 2
  end

  it 'filters by datetime' do
    res = grid.read filters: [{"type"=>"date", "operator"=>"eq", "value"=>"04/25/2011", "property"=>"last_read_at"}]
    expect(res[:total]).to eql 1

    res = grid.read filters: [{"type"=>"date", "operator"=>"gt", "value"=>"04/25/2011", "property"=>"last_read_at"}]
    expect(res[:total]).to eql 1

    res = grid.read filters: [{"type"=>"date", "operator"=>"lt", "value"=>"12/24/2010", "property"=>"last_read_at"}]
    expect(res[:total]).to eql 1

    res = grid.read filters: [{"type"=>"date", "operator"=>"gt", "value"=>"12/23/2010", "property"=>"last_read_at"}]
    expect(res[:total]).to eql 2

    res = grid.read filters: [{"type"=>"date", "operator"=>"lt", "value"=>"04/26/2011", "property"=>"last_read_at"}, {"type"=>"date", "operator"=>"gt", "value"=>"12/23/2010", "property"=>"last_read_at"}]
    expect(res[:total]).to eql 1
  end

  it 'filters by integer' do
    res = grid.read filters: [{"type"=>"integer", "operator"=>"gt", "value"=>"6", "property"=>"exemplars"}]
    expect(res[:total]).to eql 1

    res = grid.read filters: [{"type"=>"integer", "operator"=>"eq", "value"=>"5", "property"=>"exemplars"}]
    expect(res[:total]).to eql 1

    res = grid.read filters: [{"type"=>"integer", "operator"=>"eq", "value"=>"6", "property"=>"exemplars"}]
    expect(res[:total]).to eql 0
  end

  it 'filters by custom filter column' do
    res = grid.read filters: [{"type"=>"string", "value"=>"read", "property"=>"title_or_notes"}]
    expect(res[:total]).to eql 2

    res = grid.read filters: [{"type"=>"string", "value"=>"o", "property"=>"title_or_notes"}]
    expect(res[:total]).to eql 3

    res = grid.read filters: [{"type"=>"string", "value"=>"ro", "property"=>"title_or_notes"}]
    expect(res[:total]).to eql 1

    res = grid.read filters: [{"type"=>"string", "value"=>"ix", "property"=>"title_or_notes"}]
    expect(res[:total]).to eql 1
  end

  it 'filters by boolean' do
    res = grid.read filters: [{"type"=>"boolean", "value"=>true, "property"=>"digitized"}]
    expect(res[:total]).to eql 2

    res = grid.read filters: [{"type"=>"boolean", "value"=>false, "property"=>"digitized"}]
    expect(res[:total]).to eql 1
  end
end
