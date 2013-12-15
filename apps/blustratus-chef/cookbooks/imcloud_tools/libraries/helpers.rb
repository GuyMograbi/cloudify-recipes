module Enumerable
  def available?(value)
    self.include?(value) && !self[value].empty?
  end
end