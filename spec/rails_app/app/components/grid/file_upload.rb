class Grid::FileUpload < Netzke::Grid::Base
  attribute :image do |c|
    c.getter = lambda {|r| %Q(<a href='#{r.image.url}'>Download</a>) if r.image.url}
  end

  def configure(c)
    super
    c.model = Illustration
  end

  def configure_form(c)
    super
    c.attribute_overrides = {
      image: { xtype: 'fileuploadfield' }
    }
  end
end
