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
  
  def location
    Point[@components.values.map { |c| c.location.x }.min,@components.values.map { |c| c.location.y }.min]
  end
  
  def bounds
    Point[@components.values.map { |c| c.bounds.x }.max,@components.values.map { |c| c.bounds.y }.max]
  end
  
  def intersects?(visible_state)
    @components.each_value do |component|
      visible_state.components.each_value do |other_comp|
        return true if component.contains_shape?(other_comp)
      end
    end
    false
  end
  
  def update_observed(model, signal, data)
    @components.each_value { |component| component.update }
  end
  
  def draw(window, model, show_label=false)
    @components.each_value { |component| component.draw(window) }
    if !@label.nil? and (show_label or @label[:always_on]) 
      string = @label[:block].call(model)
      font = window.get_font(font_size)
      location = @components[:main].location
      font.draw(string, location.x + @text_location.x, location.y + @text_location.y, ZOrder::UI, 1.0, 1.0, @text_color)
    end
  end
  
  def handle_window_initialization(window)
    @components.each_value { |component| component.init(window) if component.respond_to?('init') }
  end
  
end