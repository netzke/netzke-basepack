class NetzkeLayoutItem < NetzkeHashRecord

  # Moving item
  def self.move_item(from, to)
    r = records.delete_at(from)
    records.insert(to, r)
    recalculate_ids
    save
  end
    
end