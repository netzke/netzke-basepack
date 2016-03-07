class GridWithInFormEditingOnly < Netzke::Grid::Base
  column :author__name do |c|
    c.editor = {min_chars: 1} # this should be passed to the form combo! TODO: test and refactor
  end

  def configure(c)
    super
    c.model = 'Book'
    c.editing = :inline
  end
end
