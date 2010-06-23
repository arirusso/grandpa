# to-do needs to be decoupled from the model-- this is a lil spaghetti-ized
#
# when behavior callbacks are called, I always pass the model in (as args[:model])... 
# this will be helpful depending on the binding of the callback, ie if it were defined in an unconventional way
class Grandpa::UiBehavior
  
  attr_writer :drag_available,
      :drag,
      :drag_release,
      :mousedown,
      :mouseup,
      :mouseover,
      :mouseout,
      :resize_available,
      :resize,
      :resize_release,
      :select_available,
      :select,
      :deselect
  
  def add(behaviors)
    behaviors.kind_of?(Array) ? behaviors.each { |behavior| add_behavior(behavior) } : add_behavior(behaviors)
  end
  
  # convenience which allows you to add behaviors to a model by passing in a symbol such as :clickable or :draggable 
  def add_behavior(behavior)
    case behavior
      when :clickable then make_clickable!
      when :draggable then make_draggable!
      when :resizable then make_resizable!
      when :selectable then make_selectable!
    end
  end
  
  def resizable?
    !@resize.nil?
  end
  
  def draggable?
    !@drag.nil? and !@drag_release.nil?
  end
  
  def clickable?
    !@mousedown.nil?
  end
  
  def selectable?
    !@select.nil? and !@deselect.nil?
  end
  
  def drop_receiver?
    !@drop_receive.nil?
  end
  
  def make_clickable!
    @mousedown ||= lambda { |args| }
    @mouseup ||= lambda { |args| }
  end
  
  def make_resizable!
    @resize_available ||= lambda { |args| }
    @resize ||= lambda { |args| }
    @resize_release ||= lambda { |args| }    
  end
  
  def make_selectable!
    @select_available ||= lambda { |args| }
    @select ||= lambda { |args|  }
    @deselect ||= lambda { |args| }
  end
  
  def make_draggable!
    @drag_available ||= lambda { |args| }
    @drag ||= lambda do |args|
      args[:model].move_by(args[:amount])
    end
    @drag_release ||= lambda { |args| }
    #@dragging_enabled = true
  end
  
  # intercepts the callback and triggers the state change signal automatically when a callback is called
  def method_missing(m, *args, &block)
    if public_methods.include?("#{m}=") # checks to see if the property is public
      @model.state_change(m.to_sym)
      return instance_variable_get("@#{m}")
    end
  end
  
  def initialize(model, options = {})
    @model = model
    @drag_available ||= options[:drag_available] 
    @drag ||= options[:drag]
    @drag_release ||= options[:drag_release]
    @mousedown ||= options[:mousedown]
    @mouseup ||= options[:mouseup]
    @mouseover ||= options[:mouseover]
    @mouseover ||= lambda { |args| }
    @mouseout ||= options[:mouseout]
    @mouseout ||= lambda { |args| }
    @resize_available ||= options[:resize_available]
    @resize ||= options[:resize]
    @resize_release ||= options[:resize_release]
    @select_available ||= options[:select_available]
    @select ||= options[:select]
    @deselect ||= options[:deselect]
    #
    add(options[:behaviors]) unless options[:behaviors].nil?
    add(options[:behavior]) unless options[:behavior].nil?
  end
  
end
