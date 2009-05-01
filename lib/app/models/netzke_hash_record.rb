class NetzkeHashRecord < Hash
  include Netzke::ActiveRecordExtensions
  #
  # Class methods
  #
  def self.widget=(w)
    @@widget = w
    reload
  end
  
  def self.widget
    @@widget ||= nil
    raise "No widget specified for NetzkeHashRecord" if @@widget.nil?
    @@widget
  end
  
  def self.data=(data)
    @@records = data
    save
  end
  
  def self.raw_data=(data)
    persistent_config.for_widget(widget) {|p| p[:layout__columns] = data}
  end
  
  def self.columns_hash
    @@columns_hash ||= build_columns_hash
  end

  def self.push(instance)
    records << instance
  end

  def self.reload
    @@records = build_records
  end

  # standard AR operations
  def self.all(params = {})
    records
  end
  
  def self.count(params = {})
    records.size
  end
  
  def self.find(*args)
    if args.size == 1
      records[args.first.to_i - 1]
    else
    end
  end
  
  def self.first
    records.first
  end
  
  def self.last
    records.last
  end
  
  def self.delete(ids)
    ids.each do |id|
      records.delete_if{|r| r.id == id.to_i}
    end
    recalculate_ids
    save
  end
  
  def self.delete_all
    records.clear
    save
  end
  
  def self.save
    records_without_ids = records.map{ |r| r.reject{ |k,v| k == :id } }
    persistent_config.for_widget(widget) {|p| p[:layout__columns] = records_without_ids}
    true
  end
  
  def self.column_names
    columns_hash.keys.sort{ |x,y| x == "id" ? -1 : 0} # "id"-column should always come first (required by the GridPanel)
  end
  
  def self.reflect_on_all_associations
    []
  end
  
  #
  # Instance methods
  # 
  def initialize(params = {})
    self.replace(params)
  end
  
  def id
    self[:id] || self["id"]
  end
  
  def id=(id)
    self[:id] = id
  end
  
  def save
    if self.id.nil?
      self.id = self.class.records.size + 1
      self.class.push(self)
    else
      # nothing to do
    end
    
    self.class.save
  end
  
  def errors
    []
  end
  
  private
  
  def self.persistent_config
    @@persistent_config ||= Netzke::Base.config[:persistent_config_manager].constantize
  end

  def self.records
    @@records ||= build_records
  end
  
  def self.build_records
    raw_records = persistent_config.for_widget(widget){|p| p[:layout__columns]} || []
    records = []
    raw_records.each_with_index do |r,i|
      own_instance = self.new(r.convert_keys{|k| k.to_sym})
      own_instance.merge!(:id => i + 1) # merging with the id
      records << own_instance
    end
    records
  end
  
  def self.recalculate_ids
    records.each_with_index { |r, i| r.id = i + 1} 
  end
  
  def self.build_columns_hash
    res = {}
    records.each do |record|
      record.keys.each do |k|
        
        if res[k.to_s].nil?
          
          # calculate column type
          column_type = case record[k].class.to_s
            when "TrueClass"
              :boolean
            when "FalseClass"
              :boolean
            when "String"
              :string
            when "Fixnum"
              :integer
            else
              :string
            end
          
          column = {:type => column_type}

          # workaround for the "type" method
          class << column
            def type
              self[:type]
            end
          end

          res[k.to_s] = column
        end
      end
    end
    res
  end
end