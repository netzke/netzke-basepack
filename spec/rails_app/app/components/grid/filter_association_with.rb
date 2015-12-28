class Grid::FilterAssociationWith < Netzke::Grid::Base
  def model
    Book
  end

  def columns
    [
      { name: :author__custom_name, text: 'Author', getter: lambda {|r| "#{r.first_name} #{r.last_name}" }, filter_association_with: lambda {|r, v| r.where('year > ?', v)} },
      { name: :title, text: 'title'},
    ]
  end
end
