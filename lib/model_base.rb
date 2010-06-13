module Grandpa::ModelBase
 
  extend Forwardable
  include Grandpa::Geom
  include Observable
 
  attr_accessor :absolute_position,
              :can_drag_proc,
              :deselect_proc,
              :dragging_enabled,
              :drag_proc,
              :drag_release_proc,
              :mousedown_proc,
              :mouseup_proc,
              :hover_proc,
              :initialized,
              :location,
              :marked_for_deletion,
              :name, 
              :nohover_proc,
              :resize_proc, 
              :resize_release_proc,
              :select_proc,
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
  
  def add_behaviors!(behaviors)
    behaviors.kind_of?(Array) ? behaviors.each { |behavior| add_behavior!(behavior) } : add_behavior!(behaviors)
  end
  
  def add_behavior!(behavior)
    case behavior
      when :clickable then make_clickable!
      when :draggable then make_draggable!
      when :resizable then make_resizable!
      when :selectable then make_selectable!
    end
  end
  
  def resizable?
    !@resize_proc.nil?
  end
  
  def draggable?
    !@drag_proc.nil? and @dragging_enabled
  end
  
  def clickable?
    !@mousedown_proc.nil?
  end
  
  def playable?
    !@play_proc.nil?
  end
  
  def selectable?
    !@select_proc.nil? and !@deselect_proc.nil?
  end
  
  def make_clickable!
     @mousedown_proc ||= lambda { |args| state_change(:mousedown!) }
     @mouseup_proc ||= lambda { |args| state_change(:end_mousedown!) }
  end
  
  def make_resizable!
    @resize_proc ||= lambda { |args| }
    @resize_release_proc ||= lambda { |args| }    
  end
  
  def make_selectable!
     @select_proc ||= lambda { |args| state_change(:select!) }
     @deselect_proc ||= lambda { |args| state_change(:de_select!) }
  end
  
  def make_draggable!
     @drag_proc ||= lambda do |args|
      state_change(:dragging!)
      move_by(args[:amount])
    end
    @can_drag_proc ||= lambda { |args| true }
    @drag_release_proc ||= lambda { |args| state_change(:end_dragging!) }
    @dragging_enabled = true
  end

  #alias_method :contains?, :intersects?
  
  def init_model
    initialize_base
  end
  
  private
  
  def initialize_children
    @children.each_value do |child|
      if child.kind_of?(Array)
        child.each { |obj| obj.move_by(@location) unless obj.absolute_position }
      else
        child.move_by(@location)  unless child.absolute_position
      end
      child.dragging_enabled = false unless !@enable_dragging_for.nil? and @enable_dragging_for.flatten.include?(child)
    end
  end
 
      
  def initialize_base(options = {})
    @initialized = false
    #@disabled_behaviors = {}
    add_behaviors!(options[:behaviors]) unless options[:behaviors].nil?
    add_behavior!(options[:behavior]) unless options[:behavior].nil?
    add_behaviors!(@behaviors) unless @behaviors.nil?
    add_behavior!(@behavior) unless @behavior.nil?
    @enable_dragging_for ||= []
    @tweens ||= []
    @dragging_enabled ||= false
    @location ||= options[:location]
    @location ||= options[:relative_location]
    @location ||= Point[0,0]
    @size ||= options[:size] 
    @marked_for_deletion ||= false   
    #@play_proc ||= lambda { |args| state_change(:play!) }
    #@after_play_proc ||= lambda { |args| state_change(:no_play!) }
    @hover_proc ||= lambda { |args| state_change(:hover!) }
    @nohover_proc ||= lambda { |args| state_change(:no_hover!) }
    @event_data_proc ||= lambda { |args| }
    @views_proc ||= options[:looks_like]
    @name ||= options[:name]
    @children ||= options[:children] || {}
    @absolute_position ||= false
    @name ||= options[:name]
    initialize_children
    @initialized = true
  end
 
end

class Grandpa::Model
  
  include Grandpa::ModelBase
  
  def initialize(options)
    initialize_base(options)
  end
  
end