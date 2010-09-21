class Grandpa::UiState
  
  attr_accessor :mousedown, :drag, :resize, :selection
  
  def initialize
    @mousedown = { :single => nil, :multi => nil }
    @drag = [] 
    @resize = []
    @selection = []
  end
  
  # delete all of the selected models
  def delete_selected
    @selection.each { |s| s.destroy! }
    deselect_all
  end
  
  # clear the selection queue
  def deselect_all
    @selection.each { |model| model.behavior.deselect.call(:model => model) }
    @selection.clear
  end
  
end