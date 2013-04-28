require 'spec_helper'

module Netzke::Basepack
  describe Grid::Services do
    it 'does not allow deleting out-of-scope records' do
      Author.delete_all

      castaneda = FactoryGirl.create(:castaneda)
      fowles = FactoryGirl.create(:fowles)

      castaneda_book1 = FactoryGirl.create(:book, author: castaneda)
      castaneda_book2 = FactoryGirl.create(:book, author: castaneda)
      castaneda_book3 = FactoryGirl.create(:book, author: castaneda)

      fowles_book1 = FactoryGirl.create(:book, author: fowles)
      fowles_book2 = FactoryGirl.create(:book, author: fowles)

      grid = BookGridWithScope.new

      # allowed
      expect {
        grid.destroy([castaneda_book1.id])
      }.to change {castaneda.books.count}.by(-1)

      # not allowed
      expect {
        grid.destroy([fowles_book1.id])
      }.to change {fowles.books.count}.by(0)

      # partially allowed
      destroyed_ids, errors = grid.destroy([
        castaneda_book2.id,
        castaneda_book3.id,
        fowles_book1.id,
        fowles_book2.id
      ])

      destroyed_ids.should == [castaneda_book2.id, castaneda_book3.id]
    end
  end
end
