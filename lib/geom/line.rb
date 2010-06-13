class Grandpa::Geom::Line
  
  #ns
  include Grandpa::Geom
  #mod
  include Grandpa::Geom::Base
  
  attr_accessor :end_point, :start_point
  
  def initialize(start_point_proc, end_point_proc, color, options = {})
    #@thickness = options[:thickness] || 1
    @start_point_proc = start_point_proc
    @end_point_proc = end_point_proc    
    @endcolor = options[:end_color] || color
    @start_point = @start_point_proc.call
    @end_point = @end_point_proc.call
    initialize_base(@start_point_proc, color, @start_point_proc, options)
  end
  
  def update
    @start_point = @start_point_proc.call
    @end_point = @end_point_proc.call
  end
  
  def draw(gosu_window)
    #@thickness.times do |i|
      gosu_window.draw_line(@start_point.x, @start_point.y, @color, @end_point.x, @end_point.y, @endcolor, @zorder)
    #end
  end
  
end
