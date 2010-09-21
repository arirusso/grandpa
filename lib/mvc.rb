module Grandpa::Mvc
  
  # namespaces
  include Grandpa
  include Grandpa::Geom
  extend Forwardable

  attr_accessor :background,
              :controller,
              :name, 
              :views,
              :window
                
  attr_reader :models, :pointer
                
  def_delegators :window, :mouse_move_amount, :mouse_position 
  
  def start!
    use_default_pointer if @pointer.nil? 
    init_mvc unless @inited
    @window.add_observer(@controller) unless @controller.nil?
    @started = true
    @background.init(@window) if @background.kind_of?(Image) && !@background.nil? 
    initialize_views 
    @window.show
    after_start if respond_to?(:after_start)
  end
  
  # this will give you the extended list of models including system models
  # like the pointer
  def all_models
    @models
  end
  
  # this will give you the set of models that the user has defined
  def models
    system_models = [@pointer]
    @models.map { |model| model unless system_models.include?(model) }.compact
  end
  
  def clicked_views
    pointer_view = find_view(@pointer)
    return [] if pointer_view.nil?
    @views.find_all { |view| view.intersects?(pointer_view) && view.model.behavior.clickable? } 
  end
  
  def exit!
    @window.close
  end
  
  def find_view(model)
    @views.find { |view| view.model.eql?(model) }
  end
  
  def use_fullscreen_fit_to_current_resolution
    @size = Rome::Platform::screen_size
    @fullscreen = true
  end
  
  def add_view_from_view_factory(view_factory, model)
    view_factory.describe_views_of(model)
    unless view_factory.states.nil? || view_factory.states.empty?
      view_manager = Grandpa::ViewManager.new(model, view_factory)
      add_view(view_manager, model)
    end
  end

  def add_view(view, associate_with, child = false)
    associate_with.add_observer(view)
    if child
      associate_with.dragging_enabled = false
    end
    #view.lazy_initialize(@window) if @started
    @views << view
  end
  
  # finds the stored ViewFactory for model
  def find_view_factory_for_model(model)
    map = @view_factories.find { |v| v[:model].eql?(model) }
    map[:factory] unless map.nil?
  end
  
  # adds a model to the model collection and instantiates its views
  def add_model(model, options={})
    init_mvc unless @inited
    model.init_model unless model.initialized?
    view_factory = options[:looks_like].nil? ? find_view_factory_for_model(model) : options[:looks_like]
    add_view_from_view_factory(view_factory, model) if find_view(model).nil?
    unless @models.include?(model)
      model.add_observer(self)
      @models << model
      # keep the view factory around incase you want to use it again later
      @view_factories << { :model => model, :factory => view_factory } unless view_factory.nil?
    end
    add_model_children(model, view_factory) if model.has_children?
    model
  end
  
  def handle_changed_children(model)
    add_model(model)
  end
  
  def draw_background
    unless @background.nil?
      @background.kind_of?(Grandpa::Image) ?
        # handle background image
        @background.draw(@window) :
          # handle solid color background
          @window.draw_quad(0, 0, @background, 0, @size.y, @background, @size.x, 0, @background, @size.x, @size.y, @background, z=0)
    end
  end
  
  def draw_views
    @views.each { |view| view.draw(@window) }
  end
  
  def destroy_model!(model)
    @models.delete(model) if model.respond_to?('marked_for_deletion') && model.marked_for_deletion
    @views.delete(find_view(model))
    GC.start
  end
  
  def update_observed(model, signal, data)
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
       unless model.eql?(@pointer) || @pointer.nil?
        model.intersects?(@pointer) ? model.behavior.mouseover.call(:model => model) : model.behavior.mouseout.call(:model => model)
       end
    end
  end
  
  def update_pointer
    @pointer.location = @window.m
  end
  
  def use_pointer(model, options={})
    model.name = :pointer
    add_model(model, options)
    @pointer = model
  end
  
  def use_simple_pointer(image)
    view = SimplePointerViewFactory.new(image)
    pointer_model = SimplePointer.new
    use_pointer(pointer_model, :looks_like => view) 
  end

  # this gives the app a 1x1 pixel black pointer
  def use_default_pointer
    pointer_view = SimplePointerViewFactory.new
    pointer_model = SimplePointer.new(Point[1,1])
    use_pointer(pointer_model, :looks_like => pointer_view)
  end
  
  private
  
  # adds the children of a model, and collects their views from the view factory
  def add_model_children(model, view_factory)
    model.children.each do |name, child|
      view = view_factory.components[name] rescue nil
      if child.kind_of?(Array)
        child.each { |obj| add_model(obj, :looks_like => view) }   
      else
        add_model(child, :looks_like => view)
      end
    end
  end
  
  
  # this is for views that require the window to be initialized
  def initialize_views
    @views.each { |v| v.handle_window_initialization(@window) }
  end
  
  def init_mvc(options = {})
    @started = false
    Thread.abort_on_exception = true  
    @models = ModelContainer.new
    @view_factories,
    @views = [],[]
    fullscreen = options[:fullscreen] || false
    size = (options[:size] || Point[1000, 600])
    @window = Grandpa::Window.new(self, size.x, size.y, fullscreen)
    name = (options[:name] || self.class.name)
    @window.caption = name
    @inited = true
  end
  
  
end