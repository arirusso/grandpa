class Grandpa::App
  # modules
  include Grandpa::Mvc
  
  def initialize(*a)
    init_mvc(*a)
  end
  
end