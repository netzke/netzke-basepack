class NetzkeLayoutItem < NetzkeHashRecord
  include Netzke::ActiveRecordExtensions
  
  #
  # Class methods
  #
  def self.widget=(w)
    if (@@widget ||= nil != w)
      @@widget = w
      reload
    end
  end
  
  def self.widget
    @@widget ||= nil
    raise "No widget specified for NetzkeHashRecord" if @@widget.nil?
    @@widget
  end

  # Moving item
  def self.move_item(from, to)
    r = records.delete_at(from)
    records.insert(to, r)
    recalculate_ids
    save
  end


  #
  # Instance methods
  # 
  def save
    if self.id.nil?
      self.id = self.class.records.size + 1
      self.class.push(self)
    else
      # nothing to do
    end
    
    self.class.save_data
  end
  
  
  #
  # Private methods
  #
  def self.save_data
    records_without_ids = records.map{ |r| r.reject{ |k,v| k == :id } }
    persistent_config.for_widget(widget) {|p| p[:layout__columns] = records_without_ids}
    true
  end
  
    
end