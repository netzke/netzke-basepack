# Holds attribute lists for application models.
# Is used to configure attributes in the layer between a model and its representation in the Netzke application, thus providing default attributes
# for grids and panels.
class NetzkeModelAttrList < NetzkeFieldList
  
  # Updates attributes for all lists owned by owner_id and below the current authority level
  def self.update_fields(owner_id, attrs_hash)
    super
    
    NetzkeFieldList.find_all_lists_under_current_authority(owner_id).each do |list|
      list.update_attrs(attrs_hash)
    end
  end
  
end
