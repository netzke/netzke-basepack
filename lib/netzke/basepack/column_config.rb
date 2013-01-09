class ColumnConfig < ActiveSupport::OrderedOptions
  def initialize(c, data_adapter)
    c = {name: c.to_s} if c.is_a?(Symbol) || c.is_a?(String)
    c[:name] = c[:name].to_s
    self.replace(c)

    @data_adapter = data_adapter
  end

  def primary?
    @data_adapter.primary_key_name == name
  end
end
