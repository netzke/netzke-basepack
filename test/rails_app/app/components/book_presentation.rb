module BookPresentation
  # A setter that creates an author on the fly
  def author_first_name_setter
    lambda do |r,v|
      if (author = Author.where(:first_name => v).first).nil?
        r.author = Author.create(:first_name => v)
      else
        r.author = author
      end
    end
  end

  # A getter that returns "YES" if exemplars are more than 3, "NO" otherwise
  def in_abundance_getter
    lambda {|r| r.exemplars.to_i > 3 ? "YES" : "NO"}
  end

end
