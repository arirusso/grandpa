module Grandpa::Controller
  
  module Base
    
    extend Forwardable
    
    DragDelay = 0.1
    ResizeDelay = 0.5
    
    def_delegators :@app, :models, :mouse_position, :mouse_move_amount, :pointer
    
    def initialize(app)
      @app = app
      @state = Grandpa::UiState.new
    end
    
    def update_observed(model, signal, data)
      signal = signal.to_s unless RUBY_VERSION >= "1.9.0"
      send(signal) if methods.include?(signal)
    end
    
    def record_mousedown(type = :single)
      clicked_on = @app.clicked_views.map { |view| view.model }
      handle_mousedown_action(clicked_on)
      @state.mousedown[type] = { :time => Time.now, :items => clicked_on }
      #@state.resize.clear
    end
    
    def handle_mouseup(type = :single)
      @app.models.each { |model| model.mouseup_proc.call({}) if model.clickable? }
      mode = select_mode(type)
      unless mode.nil?
        handle_drag_release
        #handle_resize_release
        models = @state.mousedown[type][:items]
        if models.empty?
          @state.mousedown[type] = nil
          @app.deselect_all! if mode.deselect_on_clicked_background?
        else
          
          #@app.modes[:play].handle_click(:objects => @state.mousedown[mousedown[:type]][:items], :interface => @app.interface)
          mode.handle_mousedown(models, @app.selection)
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
      models.each { |model| model.mousedown_proc.call(:selection => @app.selection) }
    end
    
    def handle_drag_action(amount, type)
      @state.drag += @state.mousedown[type][:items].find_all { |item| item.draggable? and item.can_drag_proc.call(:pointer => @app.pointer) } 
      @state.drag.uniq!
      @state.drag.each { |item| item.drag_proc.call(:amount => amount, :selection => @app.selection, :pointer => @app.pointer) }
    end
    
    def handle_drag(amount)
      types = [:single, :multi]
      types.each do |type|
        unless @state.mousedown[type].nil?
          handle_drag_action(amount, type) if @state.mousedown[type][:time] <= (Time.now - DragDelay) and @state.resize.empty?
        end
      end       
    end
    
    def select_mode(name)
      case name
        when :multi then Grandpa::SelectModes::Multi.instance
        when :single then Grandpa::SelectModes::Single.instance
      end
    end
    
  end
  
  module Clicking
    
    def left_mousedown
      record_mousedown
      #models.with_name('square').tween!(:to => mouse_position)
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