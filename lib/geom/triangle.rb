class Grandpa::Geom::Triangle

  #ns
  include Grandpa::Geom
  #mod
  include Grandpa::Viewable
  
  def draw(gosu_window)
    gosu_window.draw_line(@location.x, y_bound, @color, x_bound, y_bound, @color, @zorder)
    gosu_window.draw_line(@location.x, y_bound, @color, x_median, @location.y, @color, @zorder)
    gosu_window.draw_line(x_median, @location.y, @color, x_bound, y_bound, @color, @zorder)
  end
  
end
