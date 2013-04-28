require 'spec_helper'

module Netzke::Basepack
  describe Grid::Services do
    before do
      Author.delete_all

      @castaneda = FactoryGirl.create(:castaneda)
      @fowles = FactoryGirl.create(:fowles)

      @cb1 = FactoryGirl.create(:book, author: @castaneda)
      @cb2 = FactoryGirl.create(:book, author: @castaneda)
      @cb3 = FactoryGirl.create(:book, author: @castaneda)

      @fb1 = FactoryGirl.create(:book, author: @fowles)
      @fb2 = FactoryGirl.create(:book, author: @fowles)
    end

    let(:grid) {BookGridWithScope.new}

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

      destroyed_ids.should == [@cb2.id, @cb3.id]
    end

    it 'does not allow editing out-of-scope records' do
    end
  end
end
