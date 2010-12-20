class LockableUserForm < UserForm
  def default_config
    super.merge(
      :mode => :lockable
    )
  end
end