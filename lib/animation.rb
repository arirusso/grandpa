class Grandpa::Animation
  #ns
  include Grandpa::Geom
  #mod
  include Grandpa::Viewable
  
  def initialize(shapes, options = {})
    @shapes = shapes
    @step = 0
    @tick = 0   
    @speed = options[:speed] || 50
    size_proc = shapes.first.size_proc
    location_proc = shapes.first.location_proc
    initialize_base(size_proc, color, location_proc, options)
  end
  
  def init(gosu_window)
    @shapes.each { |shape| shape.init(gosu_window) if shape.respond_to?(:init) }
  end
  
  def update
    @tick += (100/@speed).to_i
    if @tick >= @speed
      @step = @step.eql?(@shapes.length-1) ? 0 : @step + 1
      @shapes[@step].update
      @location = @shapes[@step].location
      @size = @shapes[@step].size
      @tick = 0
    end
  end
  
  def draw(window)
    @shapes[@step].draw(window) 
  end
   
end