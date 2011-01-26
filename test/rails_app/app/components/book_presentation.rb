module BookPresentation
  # A setter that creates an author on the fly
  def author_first_name_setter
    lambda do |r,v|
      if v.is_a?(Integer)
        r.author = Author.find(v)
      else
        r.author = Author.create(:first_name => v)
      end
    end
  end

  # A getter that returns "YES" if exemplars are more than 3, "NO" otherwise
  def in_abundance_getter
    lambda {|r| r.exemplars.to_i > 3 ? "YES" : "NO"}
  end

end
