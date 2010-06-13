class Grandpa::Geom::CyclicPolygon
  
  #ns
  include Grandpa::Geom
  #mod
  include Grandpa::Geom::Base
  
  def initialize(num_sides, size, color, location, options = {})
    super(size, color, location, options)
    @sides = num_sides
  end
  
  def self.info_location
    Point.new(12,10)
  end
  
  def draw(gosu_window)
    @border.times do |pass|
      radius = (@size.x/2)-pass
      px = @location.x + pass + radius + (Math.cos(2*Math::PI) * radius)
      py = @location.y + pass + radius + (Math.sin(2*Math::PI) * radius)
      lx,ly = nil,nil
      (0..@sides).each do |i|
        ratio = (i/@sides.to_f)
        lx,ly=px,py
        px = @location.x + pass + radius + (Math.cos(ratio*2*Math::PI) * radius)
        py = @location.y + pass + radius + (Math.sin(ratio*2*Math::PI) * radius)
        gosu_window.draw_line(lx, ly, @color, px, py, @color, @zorder)
      end
    end
  end
  
end
