class Grandpa::SimplePointer
  
  include Grandpa::ViewFactory
  
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