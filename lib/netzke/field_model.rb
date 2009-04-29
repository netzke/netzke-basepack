module Netzke
  class FieldModel < Hash
    include ActiveRecordExtensions
    
    def self.new_from_hash(hsh)
      self.new.replace(hsh)
    end
    
    # def self.json=(str)
    #   @@data = ActiveSupport::JSON.decode(str)
    #   process_data
    # end

    def self.widget_name=(w)
      @@widget_name = w
    end

    def self.data_storage=(ds)
      @@storage = ds
      process_data
    end

    # def self.data=(data)
    #   @@raw_data = data
    #   process_data
    # end
    
    def self.column_names
      @@data.inject([]){|res, record| (res + record.keys).uniq}
    end
    
    def self.columns
      column_names
    end
    
    def self.all(params={})
      @@data
    end
    
    def self.first
      @@data[0]
    end
    
    def self.find(id)
      @@data[id-1]
    end
    
    def self.count(params = {})
      @@data.size
    end
    
    def self.columns_hash
      @@columns_hash
    end
    
    def self.reflect_on_all_associations
      []
    end
    
    # instance methods
    def id
      self[:id] || self["id"]
    end
    
    def errors
      []
    end
    
    def save
      true
    end
    
    private
    def self.process_data
      @@columns_hash = {}

      @@data = []
      
      # convert array of hashes into array of FieldModel instances
      @@storage.each do |hsh|
        @@data << new_from_hash(hsh)
      end

      @@data.each do |record|
        record.keys.each do |k|
          
          if @@columns_hash[k.to_s].nil?
            
            # calculate column type
            puts record[k].class.to_s
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

            @@columns_hash[k.to_s] = column
          end
        end
      end
    end

    # # Testing
    # @@data = [
    #   self.new_from_hash({"id" => 1, "name" => "col1", "column_type" => "text", "read_only" => true}),
    #   self.new_from_hash({"id" => 2, "name" => "col2", "column_type" => "string", "read_only" => false})
    # ]
    # 
    # process_data
    # end testing

  end
  
  
end