module Grandpa::Model::Base
  
  #ns
  include Grandpa::Geom
  #mod
  extend Forwardable
  include Observable
  
  attr_accessor :absolute_position,
              :behavior,
              #:can_drag_proc,
              #:dragging_enabled,
              :initialized,
              :location,
              :marked_for_deletion,
              :name, 
              :size,
              :tweens 
 
  alias_method :initialized?, :initialized
  
  def state_change(signal, data = {})
    changed
    notify_observers(self, signal, data)    
  end
  
  def move_by(amount)
    @location += amount
    @children.each_value { |child| child.move_by(amount) }
    state_change(:move!, amount)
  end
  
  def tween!(options)
    @tweens << Grandpa::Tween.new(options.merge({ :from => @location }))
  end
  
  def update
    unless @tweens.empty?
      @tweens.first.process(self)
      @tweens.shift if @tweens.first.done?(self)
    end
  end
  
  def location=(location)
    @location=location
    @children.each_value { |child| child.location+=(location) }
    state_change(:change_location!)
  end
  
  def size=(size)
    @size=size
    state_change(:change_size!)
  end
  
  def destroy!
    @marked_for_deletion = true
    @children.each_value { |child| child.destroy! }
    state_change(:destroy!)
  end
  
  def contains_point?(point)
    range_x.include?(point.x) and range_y.include?(point.y)
  end
  
  def bounds
    @location + @size
  end
  
  def range_x
   (@location.x..@location.x+@size.x)
  end
  
  def range_y
   (@location.y..@location.y+@size.y)
  end
  
  def intersects?(other_model)
    other_model.bounds.x >= location.x and
    other_model.bounds.y >= location.y and
    other_model.location.x <= bounds.x and
    other_model.location.y <= bounds.y  
  end
  
  def in_resize_zone?(pointer_view)
    pointer.x_range.include?(bounds.x) and pointer.y >= @location.y and pointer.y_bound <= bounds.y
  end
  
  def enable_dragging_for(objects)
    @enable_dragging_for += objects
    objects.flatten.each { |model| model.dragging_enabled = true } if @initialized
  end
  
  #alias_method :contains?, :intersects?
  
  def init_model
    initialize_base((@callback || {}))
    @callback = nil
  end
  
  def has_children?
    respond_to?(:children) and !children.empty?
  end
  
  def initialize(options = {})
    initialize_base(options)
  end
  
  private
  
  def initialize_children
    @children.each_value do |child|
      if child.kind_of?(Array)
        child.each { |obj| obj.move_by(@location) unless obj.absolute_position }
      else
        child.move_by(@location)  unless child.absolute_position
      end
      #child.dragging_enabled = false unless !@enable_dragging_for.nil? and @enable_dragging_for.flatten.include?(child)
    end
  end
  
  def initialize_base(options = {})
    @initialized = false
    #@disabled_behaviors = {}
    @enable_dragging_for ||= []
    @tweens ||= []
    #@dragging_enabled ||= false
    @location ||= options[:location]
    @location ||= options[:relative_location]
    @location ||= Point[0,0]
    @size ||= options[:size] 
    @marked_for_deletion ||= false
    options[:behavior] ||= @behavior
    @behavior = Grandpa::UiBehavior.new(self, options)
    #@views_proc ||= options[:looks_like]
    @name ||= options[:name]
    @children ||= options[:children] || {}
    @absolute_position ||= false
    @name ||= options[:name]
    initialize_children
    @initialized = true
  end
  
end

# class version
class Grandpa::BasicModel
  include Grandpa::Model::Base
end