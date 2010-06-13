module Grandpa::Mvc
  
  # namespaces
  include Grandpa
  include Grandpa::Geom
  extend Forwardable
  #extend Callbacks

  attr_accessor :background,
              :controller,
              :models,
              #:pointer_image,
              :name,
              :selection,
              :size, 
              :views,
              :window
                
  def_delegators :window, :mouse_move_amount, :mouse_position 
  
  def start!
    init_mvc unless @inited
    @window = Grandpa::Window.new(self, @size.x, @size.y, @fullscreen)
    @window.add_observer(@controller) unless @controller.nil?
    @window.caption = @name
    @started = true
    @background.init(@window) if @background.kind_of?(Image) and !@background.nil? 
    #init_pointer
    #@pointer = Pointer.new(@window, @pointer_image[:base], :resize_image => @pointer_image[:resize], :zorder => 10)
    lazy_initialize_if_needed 
    @window.show
    after_start if respond_to?(:after_start)
  end
  
  def exit!
    @window.close
  end
  
  def clicked_views
    @views.find_all { |view| view.intersects?(find_view(@pointer)) and view.model.clickable? }
  end
  
  def find_view(model)
    @views.find { |view| view.model.eql?(model) }
  end

  def delete_selection!
    @selection.each { |s| s.destroy! }
  end
  
  def use_fullscreen_fit_to_current_resolution
    @size = Rome::Platform::screen_size
    @fullscreen = true
  end
  
  def add_view_from_class(view, model)
    view.describe_view_of(model) # yes, this method has a weird name
    # what it actually does is build the view using the model that is passed in.
    # the naming is done for higher-level convenience (see Views example)
    unless view.states.nil? or view.states.empty?
      view = Grandpa::VisibleStateManager.new(model, view)
      add_view(view, model)
    end
  end

  def add_view(view, associate_with, child = false)
    associate_with.add_observer(view)
    if child
      associate_with.dragging_enabled = false
    end
    view.lazy_initialize(@window) if @started
    @views << view
  end
  
  def add_model(model, options={})
    init_mvc unless @inited
    model.init_model unless model.initialized?
    if options[:looks_like].nil?
      map = @view_factories.find { |v| v[:model].eql?(model) }
      view_factory = map[:factory] unless map.nil?
    else
      view_factory = options[:looks_like]
    end
    add_view_from_class(view_factory, model) if find_view(model).nil?
    unless @models.include?(model)
      model.add_observer(self)
      @models << model
      @view_factories << { :model => model, :factory => view_factory } unless view_factory.nil?
    end
    if model.respond_to?(:children) and !model.children.empty?
      model.children.each do |name, child|
        view = view_factory.components[name] rescue nil
        if child.kind_of?(Array)
          child.each { |obj| add_model(obj, :looks_like => view) }   
        else
          add_model(child, :looks_like => view)
        end
      end
    end
    model
  end
  
  def handle_changed_children(model)
    add_model(model)
  end
  
  def draw_background
    unless @background.nil?
      @background.kind_of?(Grandpa::Image) ?
        @background.draw(@window) :
          @window.draw_quad(0, 0, @background, 0, @size.y, @background, @size.x, 0, @background, @size.x, @size.y, @background, z=0)
    end
  end
  
  #def draw_pointer
  #  @pointer.draw(@window)
  #end
  
  def draw_views
    @views.each { |view| view.draw(@window) }
  end
  
  def pointer
    @models.with_name(:pointer)
  end
  
  def destroy_model!(model)
    @models.delete(model) if model.respond_to?('marked_for_deletion') and model.marked_for_deletion
    @views.delete(find_view(model))
    GC.start
  end
  
  def update_observed(model, signal, data)
    #handle_event(signal) if model.kind_of?(EventHander)
    case signal
      when :destroy! then destroy_model!(model) 
      when :children_added! then add_model(model)
    end
  end
  
  def update
    before_update_callback if respond_to?(:before_update_callback)
    update_models
    update_pointer unless @pointer.nil?
    after_update_callback if respond_to?(:after_update_callback)
  end
  
  def update_models
    @models.each do |model|
       model.update
       model.intersects?(@pointer) ? model.hover_proc.call({}) : model.nohover_proc.call({}) unless @pointer.nil?
    end
  end
  
  def update_pointer
    pointer.location = @window.m
  end
  
  def deselect_all!
    @selection.each { |selectable| selectable.deselect_proc.call({}) }
    @selection.clear
  end
  
  def delete_selected!
    delete_selection!
    deselect_all
  end
  
  def use_pointer(model, options={})
    model.name = :pointer
    add_model(model, options)
    @pointer = model
  end
  
  def use_simple_pointer(image)
      view = Class.new do
  
        include Grandpa::ViewBase
        
        def initialize(image)
          @image = image
          super()
        end
        
        def describe_view_of(model)
          state :base do
            has :component => Image.new(@image, bind_to(model, :size), bind_to(model, :location), :zorder => 20) 
          end
        end
  
      end.new(image)
      pointer_model = Grandpa::Model.new(:name => :pointer, :size => Point[12,12])
      use_pointer(pointer_model, :looks_like => view) 
  end
  
  private
  
  # this is for views that require the window to be initialized
  def lazy_initialize_if_needed
    @views.each { |v| v.lazy_initialize(@window) }
  end
  
  def init_mvc(options = {})
    @started = false
    @name ||= options[:name] || :Grandpa
    Thread.abort_on_exception = true  
    @models = ModelContainer.new
    @selection,
    @view_factories,
    @views = [],[],[]
    @size ||= Point[1000, 600]
    @fullscreen = false
    @inited = true
  end
  
  
end