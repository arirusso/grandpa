class Grandpa::Image
  #ns
  include Grandpa::Geom
  #mod
  include Grandpa::Geom::Base
  
  def initialize(path, size_proc, location_proc, options = {})
    @path = path
    window = options[:window]
    color = options[:color] || 0xffffffff
    @alpha = options[:alpha] || :default # or :additive
    initialize_base(size_proc, color, location_proc, options)
    init(window) unless window.nil?
  end
  
  def init(gosu_window)
    #p gosu_window.class
    @image = Gosu::Image.new(gosu_window, @path, false)
    @factor = lambda { Point[@size.x.to_f/@image.width, @size.y.to_f/@image.height] }    
  end
  
  def draw(window)
    @image.draw(@location.x, @location.y, @zorder, @factor.call.x, @factor.call.y, @color, @alpha) 
  end
   
end