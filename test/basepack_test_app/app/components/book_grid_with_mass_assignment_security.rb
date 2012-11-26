class BookGridWithMassAssignmentSecurity < Netzke::Basepack::Grid
  def configure(c)
    c.model = "Book"
    # Only allow assigning those attributes that are accessible for the :user role in the Book model
    c.role = :user

    super
  end
end
