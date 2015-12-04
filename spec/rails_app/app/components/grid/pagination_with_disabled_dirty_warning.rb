class Grid::PaginationWithDisabledDirtyWarning < Grid::Pagination
  def configure(c)
    super
    c.disable_dirty_page_warning = true
  end
end
