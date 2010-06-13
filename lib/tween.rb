class Grandpa::Tween
  
  include Grandpa::Geom
  
  def initialize(options={})
    @to = options[:to]
    @complete = options[:complete]
    @factor = 8
  end
  
  def process(obj)
    
    return if obj.location.nil?
    if ((@to.x-@factor)..(@to.x+@factor)).include?(obj.location.x)
      obj.location=Point[@to.x, obj.location.y]
    end
    if ((@to.y-@factor)..(@to.y+@factor)).include?(obj.location.y)
      obj.location=Point[obj.location.x, @to.y]
    end
    if obj.location.x < @to.x
      obj.move_by(Point[@factor,0])
    elsif obj.location.x > @to.x
      obj.move_by(Point[-@factor,0])
    end
    if obj.location.y < @to.y
      obj.move_by(Point[0,@factor])
    elsif obj.location.y > @to.y
      obj.move_by(Point[0,-@factor])
    end
    if done?(obj)
      done = true
      obj.location = @to
      @complete.call if !@complete.nil?
    end
    done
  end
  
  def done?(obj)
    zone_loc = Point[@to.x-@factor, @to.y-@factor]
    zone_size = @factor*2
    x_range = (zone_loc.x..zone_loc.x+zone_size)
    y_range = (zone_loc.y..zone_loc.y+zone_size)
    x_range.include?(obj.location.x) and y_range.include?(obj.location.y)
  end
  
end