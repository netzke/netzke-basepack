class Form::FileUpload < Netzke::Basepack::Form
  attribute :image do |c|
    c.xtype = "fileuploadfield"
    c.id = "foobar"
  end

  attribute :image_url do |c|
    c.getter = lambda {|r| %Q(<a href='#{r.image.url}'>Download</a>) if r.image.url}
    c.xtype = :displayfield
  end

  def configure(c)
    super

    c.model = Illustration

    c.title = "Default title"

    c.items = [
      :id,
      :title,
      :image,
      :image_url
    ]
  end

  endpoint :submit do |params|
    client.set_title(client_config.title)
    super params
  end
end
