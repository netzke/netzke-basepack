class Grid::PagingWithDisabledDirtyWarning < Grid::Paging
  def configure(c)
    super
    c.disable_dirty_page_warning = true
  end
end
