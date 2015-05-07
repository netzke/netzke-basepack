require 'spec_helper'

describe ::Grid::Scoped do
  # Grid with books scoped out to the first existing author (@castaneda in this case)
  let(:grid) {::Grid::Scoped.new}

  before do
    @castaneda = FactoryGirl.create(:castaneda)
    @fowles = FactoryGirl.create(:fowles)

    @cb1 = FactoryGirl.create(:book, author: @castaneda)
    @cb2 = FactoryGirl.create(:book, author: @castaneda)
    @cb3 = FactoryGirl.create(:book, author: @castaneda)

    @fb1 = FactoryGirl.create(:book, author: @fowles)
    @fb2 = FactoryGirl.create(:book, author: @fowles)
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

    destroyed_ids.should == {@cb2.id => 'ok', @cb3.id => 'ok'}
  end

  it 'does not allow editing out-of-scope records' do
    # allowed
    res = grid.update([{"id" => @cb1.id, title: 'Foo'}])
    res[@cb1.id][:error].should be_blank
    @cb1.reload
    @cb1.title.should == 'Foo'

    # not allowed
    res = grid.update([{"id" => @fb1.id, title: 'Foo'}])
    res[@fb1.id][:error].should be_present
    @fb1.reload
    @fb1.title.should_not == 'Foo'
  end

  it 'sets strongs attributes' do
    res = grid.update([{"id" => @cb1.id, title: 'Foo', author_id: @fowles.id}])
    @cb1.reload
    @cb1.author.should == @castaneda
  end

  it 'only lists scoped records' do
    grid = ::Grid::Scoped.new load_inline_data: true
    grid.js_config[:inline_data][:total].should == 3
  end
end
