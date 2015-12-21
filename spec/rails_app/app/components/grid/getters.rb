class Grid::Getters < Netzke::Grid::Base
  def configure(c)
    super
    c.model = Book
  end

  def columns
    [
        { name: :author__custom_name, text: 'Author', getter: lambda {|r| "#{r.first_name} #{r.last_name} (#{r.prize_count})" } },
        { name: :author__books__first__custom_name, text: 'first book', getter: lambda {|r| "#{r.title}(#{r.published_on})" } },
        { name: :custom_name, text: 'Book name', getter: lambda {|r| "#{r.title}, published #{r.published_on}" } }
    ]
  end
end
