class Grandpa::ViewManager
  
  #ns
  include Grandpa::Geom
  #mod
  extend Forwardable
  
  attr_accessor :model, 
                :states, 
                :staged_states
  
  def initialize(model, view, options={})
    @model = model
    @states = {}
    states = view.states
    states.each { |key,view| @states[key] = view }
    @staged_states = [@states[:base]]
  end
  
  def deep_copy(new_model)
    mgr = self.class.allocate
    mgr.model = new_model
    mgr.staged_states = @staged_states.map { |state| state.deep_copy(new_model) }
    mgr.states = {}
    @states.each { |k,v| mgr.states[k] = v } 
    mgr
  end
  
  #def in_resize_zone?(other_view)
  #  visible_state.intersects?(other_view.visible_state) and 
  #    other_view.visible_state.location.x <= visible_state.bounds.x and 
  #      other_view.visible_state.bounds.x >= visible_state.bounds.x
  #end

  #def info_location
  #  Point[10,8]  
  #end
  
  def handle_state_change(signal)
    signal = signal.to_s.chop # get rid of the exclamation point
    # parse the signal
    operator = signal.split('_').first 
    if operator.eql?('no') or operator.eql?('de') or operator.eql?('end')
      state = signal.split('_')[1]
      remove_visible_state(state.to_sym)
    else
      add_visible_state(signal.to_sym)
    end
  end
  
  def update_observed(model, signal, data)
    case signal
      # these are exceptional cases
      when :de_assoc! then delete_associated_visible_state(data)
      when :hover! then insert_visible_state(:hover) # hover gets inserted instead of added
      else handle_state_change(signal)
    end
    all_states.each { |s| s.update_observed(model, signal, data) if s.respond_to?('update_observed') }
  end

  # all states, staged an stored
  def all_states
    (@states.values | @staged_states).flatten.uniq
  end
  
  # the state which is currently at the top of the stage stack (ie visible)
  def visible_state
    @staged_states.last
  end

  # finds the staged visible state associated with the passed in item
  def get_associated_visible_state(assoc)
    @staged_states.find { |v| !v.associated.nil? and v.associated.eql?(assoc) }
  end

  # deletes the visible state associated with the passed in item from the stage
  def delete_associated_visible_state(assoc)
    @staged_states.delete(get_associated_visible_state(assoc))
  end
  
  # sends the surface down to the lower level shape objects in order to draw them 
  # on the window uses the colors,shapes and locations from the visual state on top 
  # of the stack
  def draw(surface, show_label = false)
    visible_state.draw(surface, @model, show_label)
  end
  
  def lazy_initialize(window)
    all_states.each { |state| state.lazy_initialize(window) }
  end
  
  # pushes a visible state to the stage
  # accepts either symbol or state
  def add_visible_state(state)
    @staged_states << @states[state] unless @states[state].nil?
  end
  
  def insert_visible_state(state)
    if @staged_states.length.eql?(1)
      add_visible_state(state)
    else
      @staged_states.insert(-2, @states[state]) unless @states[state].nil?
    end
  end
  
  def intersects?(view)
    visible_state.intersects?(view.visible_state)
  end
  
  # removes a visible state from the stage
  def remove_visible_state(sym)
    @staged_states.delete(@states[sym])
  end
    
end