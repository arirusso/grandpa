class Grandpa::UiState
  
  attr_accessor :mousedown, :drag, :resize
  
  def initialize
    @mousedown = { :single => nil, :multi => nil }
    @drag = [] 
    @resize = []
  end
  
end