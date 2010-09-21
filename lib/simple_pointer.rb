class Grandpa::SimplePointer
  
  include Grandpa::Model::Base 
  
  def initialize(size = nil)
    initialize_base(:name => :pointer, :size => (size || Point[12,12]))
  end
  
end

class Grandpa::SimplePointerViewFactory < Grandpa::ViewFactory
  
  def initialize(image = nil)
    @image = image
    super()
  end
  
  def describe_views_of(model)
    state :base do
      unless @image.nil?
        has :component => Image.new(@image, bind_to(model, :size), bind_to(model, :location), :zorder => 20)
      else
        has :component => Rectangle.new(bind_to(model, :size), 0xff000000, bind_to(model, :location), :zorder => 20)
      end
    end
  end
  
end