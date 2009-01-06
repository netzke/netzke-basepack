module Netzke
  # GUI for Preference class
  class PreferenceGrid < PropertyGrid
    def initialize(*args)
      super
      config[:default_properties] ||= []
      NetzkePreference.widget_name = config[:host_widget_name]
      
      # Create default properties
      config[:default_properties].each do |p|
        NetzkePreference[p[:name]] = p[:value] if NetzkePreference[p[:name]].nil?
      end
    end
    
    def load_source(params = {})
      # config[:data_class_name] = 'NetzkePreference'
      config[:conditions] ||= {}
      
      data_class = NetzkePreference
      records = data_class.find(:all, :conditions => {:widget_name => config[:host_widget_name]})
      
      NetzkePreference.widget_name = config[:host_widget_name]
      
      source = {}
      records.each do |r|
        source.merge!(r.name => NetzkePreference[r.name])
      end
      
      {:source => source}
    end
    
    def submit_source(params = {})
      data = JSON.parse(params[:data])
      NetzkePreference.widget_name = config[:host_widget_name]
      data.each_pair do |k,v|
        NetzkePreference[k.underscore] = v
      end
      
      {:success => true, :flash => @flash}
    end
    
  end
end