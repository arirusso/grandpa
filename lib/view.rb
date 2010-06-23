class Grandpa::View
  
  #namespaces
  include Grandpa::Geom
  #modules
  extend Forwardable
  
  attr_accessor :associated,
                :components,
                :font_size,
                :label,
                :text_color,
                :text_location

  
  def initialize(options={})
    @components = options[:components] || {}
    #
    @components[:main] = options[:component] unless options[:component].nil?
    #
    @text_location = options[:text_location] || Point[5,5]
    @text_color = options[:text_color] || 0xffcccccc
    @font_size = options[:font_size] || 18
    @associated = options[:associate_with]
  end
  
  # the top-left-most position values for its components
  def location
    Point[@components.values.map { |c| c.location.x }.min,@components.values.map { |c| c.location.y }.min]
  end
  
  # the bottom-right-most position values for its components
  def bounds
    Point[@components.values.map { |c| c.bounds.x }.max,@components.values.map { |c| c.bounds.y }.max]
  end
  
  # do any of my components intersect components from the passed in view? 
  def intersects?(view)
    @components.each_value do |component|
      view.components.each_value do |other_comp|
        return true if component.contains_shape?(other_comp)
      end
    end
    false
  end
  
  # let my components know that model properties have been updated
  def update
    @components.each_value { |component| component.update }
  end
  
  # draw my components
  def draw(window, model, show_label=false)
    @components.each_value { |component| component.draw(window) }
    if !@label.nil? and (show_label or @label[:always_on]) 
      string = @label[:block].call(model)
      font = window.get_font(font_size)
      location = @components[:main].location
      font.draw(string, location.x + @text_location.x, location.y + @text_location.y, ZOrder::UI, 1.0, 1.0, @text_color)
    end
  end
  
  # the gosu window has been initialized, send it to the components in case they need it
  def handle_window_initialization(window)
    @components.each_value { |component| component.init(window) if component.respond_to?('init') }
  end
  
end