# tween a model from one position to another
class Grandpa::Tween
  
  include Grandpa::Geom
  
  # @to - Geom::Point of the destination position
  # @complete - callback to be called when completed
  def initialize(options={})
    @to = options[:to]
    @complete = options[:complete]
    @factor = 8
  end
  
  # make the next move
  def process(model)
    return if model.location.nil?
    if ((@to.x-@factor)..(@to.x+@factor)).include?(model.location.x)
      model.location=Point[@to.x, model.location.y]
    end
    if ((@to.y-@factor)..(@to.y+@factor)).include?(model.location.y)
      model.location=Point[model.location.x, @to.y]
    end
    if model.location.x < @to.x
      model.move_by(Point[@factor,0])
    elsif model.location.x > @to.x
      model.move_by(Point[-@factor,0])
    end
    if model.location.y < @to.y
      model.move_by(Point[0,@factor])
    elsif model.location.y > @to.y
      model.move_by(Point[0,-@factor])
    end
    if done?(model)
      done = true
      model.location = @to
      @complete.call if !@complete.nil?
    end
    done
  end
  
  # check if complete
  def done?(model)
    zone_loc = Point[@to.x-@factor, @to.y-@factor]
    zone_size = @factor*2
    x_range = (zone_loc.x..zone_loc.x+zone_size)
    y_range = (zone_loc.y..zone_loc.y+zone_size)
    x_range.include?(model.location.x) and y_range.include?(model.location.y)
  end
  
end