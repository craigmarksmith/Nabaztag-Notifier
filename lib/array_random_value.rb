class Array
  def random_value
    self[(rand * self.size).to_i]
  end
end