class LockableBookForm < BookForm
  def configure(c)
    super
    c.mode = :lockable
  end
end
