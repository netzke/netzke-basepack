class Grid::Getters < Netzke::Basepack::Grid
  def configure(c)
    super
    c.model = Book
  end

  def columns
    [
        { name: :author__custom_name, text: 'Author', getter: ->(r){ "#{r.first_name} #{r.last_name} (#{r.prize_count})" } },
        { name: :author__books__first__custom_name, text: 'first book', getter: ->(r){ "#{r.title}(#{r.published_on})" } },
        { name: :custom_name, text: 'Book name', getter: ->(r){"#{r.title}, published #{r.published_on}" } }
    ]
  end
end
