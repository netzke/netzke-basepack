require 'spec_helper'

describe "Grid scope option" do
  # Grid with books scoped out to the first existing author (@castaneda in this case)
  let(:grid) {::Grid::Scoped.new}

  before do
    @castaneda = FactoryGirl.create(:castaneda)
    @fowles = FactoryGirl.create(:fowles)
    @hesse = FactoryGirl.create(:hesse)

    @cb1 = FactoryGirl.create(:book, author: @castaneda, title: 'Journey to Ixtlan')
    @cb2 = FactoryGirl.create(:book, author: @castaneda)
    @cb3 = FactoryGirl.create(:book, author: @castaneda)

    @fb1 = FactoryGirl.create(:book, author: @fowles)
    @fb2 = FactoryGirl.create(:book, author: @fowles)

    @hb1 = FactoryGirl.create(:book, author: @hesse)
  end

  it 'does not allow deleting out-of-scope records' do
    # allowed
    expect {
      grid.destroy([@cb1.id])
    }.to change {@castaneda.books.count}.by(-1)

    # not allowed
    expect {
      grid.destroy([@fb1.id])
    }.to change {@fowles.books.count}.by(0)

    # partially allowed
    destroyed_ids, errors = grid.destroy([
      @cb2.id,
      @cb3.id,
      @fb1.id,
      @fb2.id
    ])

    expect(destroyed_ids).to eql(@cb2.id => 'ok', @cb3.id => 'ok')
  end

  it 'does not allow editing out-of-scope records' do
    # allowed
    res = grid.update([{"id" => @cb1.id, title: 'Foo'}])
    expect(res[@cb1.id][:error]).to be_blank
    @cb1.reload
    expect(@cb1.title).to eql 'Foo'

    # not allowed
    res = grid.update([{"id" => @fb1.id, title: 'Foo'}])
    expect(res[@fb1.id][:error]).to be_present
    @fb1.reload
    expect(@fb1.title).to_not eql 'Foo'
  end

  it 'sets strongs attributes on update' do
    grid.update([{"id" => @cb1.id, title: 'New Title', notes: "Attempted"}])
    @cb1.reload
    expect(@cb1.title).to eql 'New Title'
    expect(@cb1.notes).to eql 'Fixed'
  end

  it 'sets strongs values on create' do
    grid.create([{title: 'Foo', author_id: @fowles.id}])
    book = Book.last
    expect(book.author).to eql @castaneda
  end

  it 'only lists scoped records' do
    grid = ::Grid::Scoped.new load_inline_data: true
    expect(grid.read[:data].size).to eql 3
  end

  it 'lists records from overridden scope' do
    grid = ::Grid::ScopedExtended.new load_inline_data: true
    expect(grid.read[:data].size).to eql 1
  end
end
