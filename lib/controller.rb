module Grandpa::Controller
  
  module Base
    
    extend Forwardable
    
    DragDelay = 0.1
    ResizeDelay = 0.5
    
    def_delegators :@app, :models, :mouse_position, :mouse_move_amount, :pointer
    
    def initialize(app)
      @app = app
      @state = Grandpa::UiState.new
      @select_modes = { :multi => Grandpa::SelectMode::Multi.new, :single => Grandpa::SelectMode::Single.new }
    end
    
    def update_observed(model, signal, data)
      signal = signal.to_s unless RUBY_VERSION >= "1.9.0"
      send(signal) if methods.include?(signal)
    end
        
    def handle_mousedown(select_type = :single)
      models_clicked_on = @app.clicked_views.map { |view| view.model }
      handle_mousedown_action(models_clicked_on)
      @state.mousedown[select_type] = { :time => Time.now, :items => models_clicked_on }
    end
    
    def handle_mouseup(type = :single)
      @app.models.each { |model| model.mouseup_proc.call({}) if model.clickable? }
      mode = @select_modes[type]
      unless mode.nil?
        handle_drag_release
        #handle_resize_release
        models = @state.mousedown[type][:items]
        if models.empty?
          @state.mousedown[type] = nil
          @state.deselect_all if mode.deselect_on_clicked_background?
        else
          mode.handle_mousedown(models, @state.selection)
          @state.mousedown[type] = nil
        end
      end
    end
    
    def handle_drag_release
      @app.views.each do |view|
        receiver = view.model
        receiver.receive_proc.call(:model => receiver, :items => @state.drag) if receiver.respond_to?(:receive_proc)
      end
      @state.drag.each { |draggable| draggable.drag_release_proc.call(:pointer => @app.pointer) }
      @state.drag.clear
    end
    
    def handle_mousedown_action(models)
      models.each { |model| model.mousedown_proc.call(:selection => @state.selection) }
    end
    
    def get_draggable(type)
      @state.mousedown[type][:items].find_all { |model| model.draggable? and model.can_drag_proc.call(:pointer => @app.pointer) }
    end
    
    def handle_drag_action(amount, type)
      @state.drag += get_draggable(type)
      @state.drag.uniq!
      @state.drag.each { |item| item.drag_proc.call(:amount => amount, :selection => @state.selection, :pointer => @app.pointer) }
    end
    
    def dragging_allowed?(type)
      (!@state.mousedown[type].nil? and @state.mousedown[type][:time] <= (Time.now - DragDelay) and @state.resize.empty?)  
    end
    
    def handle_drag(amount)
      @select_modes.each_key { |type| handle_drag_action(amount, type) if dragging_allowed?(type) }
    end
  
    
  end
  
  module Clicking
    
    def left_mousedown
      handle_mousedown
    end
    
    def left_mouseup
      handle_mouseup
    end
    
  end
  
  module Dragging
    
    include Clicking
    
    def mouse_move
      handle_drag(mouse_move_amount)
    end
    
  end
end