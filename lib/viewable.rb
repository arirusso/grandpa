# methods which will be called on view components (shapes, images, etc) 
module Grandpa::Viewable
  
  #ns
  include Grandpa::Geom
  #mod
  extend Forwardable
  
  attr_accessor :color,
                :location,
                :location_proc,
                :size,
                :size_proc

  def_delegators :@location,
                 :x,
                 :y
                 
  def_delegators :@size,
                 :width,
                 :height
                 
  alias_method :h, :height
  alias_method :position, :location
  alias_method :w, :width
  
  # does shape share y axis space with this instance?
  def horizontally_aligned?(shape)
    shape.y >= y and shape.y_bound <= y_bound
  end

  # does shape share x axis space with this instance
  def vertically_aligned?(shape)
    shape.x >= x and shape.x_bound <= x_bound
  end
  
  def bounds
    @location + @size
  end
  
  # expects size and location to be Point objects
  def initialize(size, color, location, options = {})
    initialize_base(size,color,location,options)
  end
  
  # the x coordinates of this instance as a range
  def x_range
    (x..x+w)
  end
  
  # the y coordinates of this instance as a range
  def y_range
    (y..y+h)
  end
  
  # the median point of the x axis
  def x_median
    @location.x+(@size.x/2)
  end

  # the median point of the y axis
  def y_median
    @location.y+(@size.y/2)
  end
  
  # the end point of the x axis
  def x_bound
    x + w
  end
  
  # the end point of the y axis
  def y_bound
    y + h
  end

  # the center Point of the object
  def center
    Point.new(x+(w/2),y+(h/2))
  end
  
  # are this object and shape intersecting?
  def intersects?(shape)
    contains_point?(shape.location) or
    contains_point?(Point[shape.x_bound, shape.y]) or
    contains_point?(Point[shape.x, shape.y_bound]) or
    contains_point?(Point[shape.x_bound, shape.y_bound]) or
    shape.contains_point?(location) or
    shape.contains_point?(Point[x_bound, y]) or
    shape.contains_point?(Point[x, y_bound]) or
    shape.contains_point?(Point[x_bound, y_bound])
  end
  
  # is point contained within this object's bounds?
  def contains_point?(point)
    (x..x_bound).include?(point.x) and (y..y_bound).include?(point.y)
  end
  
  # is the entire shape within this object's bounds?
  def contains_shape?(shape)
    shape.x_bound >= x and
    shape.y_bound >= y and
    shape.x <= x_bound and
    shape.y <= y_bound
  end
  
  def move_by(amount)
    @location += amount
  end
  
  def resize_by(amount)
    @size += amount
  end
  
  # hook
  def update
    @size = @size_proc.call
    @location = @location_proc.call
  end
  
  alias_method :contains_pointer?, :contains_shape?
  
  # is shape over the specified edge of this object?
  def over_edge?(shape, edge)
    case edge
    when :right
      shape.x_range.include?(x_bound) and horizontally_aligned?(shape)
    when :left
      shape.x_range.include?(x) and horizontally_aligned?(shape)
    when :top
      shape.y_range.include?(y) and vertically_aligned?(shape)
    when :bottom
      shape.y_range.include?(y_bound) and vertically_aligned?(shape)
    else
      throw :invalidEdge
    end
  end
  
  # is shape over a corner of this object? (uses the gosu corner numbers)
  def over_corner?(shape)
    return 0 if (shape.x_range.include?(x) and shape.y_range.include?(y))
    return 1 if (shape.x_range.include?(x+w) and shape.y_range.include?(y))
    return 2 if (shape.x_range.include?(x+w) and shape.y_range.include?(y+h))
    return 3 if (shape.x_range.include?(x) and shape.y_range.include?(y+h))
    false
  end
  
  private
  
  def initialize_base(size_proc, color, location_proc, options = {})
    @size_proc = size_proc
    @location_proc = location_proc
    @size = @size_proc.call
    @location = @location_proc.call
    @color = color
    @border = options[:border] || 1
    @zorder = options[:zorder] || 5
    @bgcolor = options[:bgcolor]
  end
 
end