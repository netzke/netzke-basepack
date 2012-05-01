class BookGridWithMassAssignmentSecurity < Netzke::Basepack::GridPanel
  def configure
    super
    config.model = "Book"

    # Only allow assigning those attributes that are accessible for the :user role in the Book model
    config.role = :user
  end
end
