class Grandpa::Geom::Rectangle
  
  #ns
  include Grandpa::Geom
  #mod
  include Grandpa::Geom::Base
  
  def draw(gosu_window)
    gosu_window.draw_quad(x, y, @bgcolor, x_bound, y, @bgcolor, x_bound, y_bound, @bgcolor, x, y_bound, @bgcolor, @zorder) unless @bgcolor.nil?
    @border.times do |i|
      gosu_window.draw_line(x, y+i, @color, x_bound, y+i, @color, @zorder)
      gosu_window.draw_line(x_bound-i, y, @color, x_bound-i, y_bound, @color, @zorder)
      gosu_window.draw_line(x, y_bound-i, @color, x_bound, y_bound-i, @color, @zorder)
      gosu_window.draw_line(x+i, y-1, @color, x+i, y_bound, @color, @zorder) # re: @location.y-1 here - http://www.libgosu.org/cgi-bin/mwf/topic_show.pl?tid=276
    end
  end
  
end
