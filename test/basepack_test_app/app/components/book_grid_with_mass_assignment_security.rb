class BookGridWithMassAssignmentSecurity < Netzke::Basepack::GridPanel
  def configure(c)
    super
    c.model = "Book"

    # Only allow assigning those attributes that are accessible for the :user role in the Book model
    c.role = :user
  end
end
