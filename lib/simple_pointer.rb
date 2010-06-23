class Grandpa::SimplePointer
  
  include Grandpa::Model::Base 
  
  def initialize
    initialize_base(:name => :pointer, :size => Point[12,12])
  end
  
end

class Grandpa::SimplePointerViewFactory < Grandpa::ViewFactory
  
  def initialize(image)
    @image = image
    super()
  end
  
  def describe_views_of(model)
    state :base do
      has :component => Image.new(@image, bind_to(model, :size), bind_to(model, :location), :zorder => 20) 
    end
  end
  
end