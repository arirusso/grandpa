class Grandpa::UiState
  
  attr_accessor :mousedown, :drag, :resize, :selection
  
  def initialize
    @mousedown = { :single => nil, :multi => nil }
    @drag = [] 
    @resize = []
    @selection = []
  end
  
  def delete_selected
    @selection.each { |s| s.destroy! }
    deselect_all
  end
  
  def deselect_all
    @selection.each { |model| model.deselect_proc.call({}) }
    @selection.clear
  end
  
end