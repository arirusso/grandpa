require 'grandpa'

# this simple example displays an animated square. its colors change when it's clicked on, and it can be dragged around the screen
class DraggingApp
  include Grandpa::Mvc
  
  class Model
    
    include Grandpa::ModelBase
    
    def initialize
      @name = 'square'
      @location = Point[100,100] 
      @size = Point[10,10]
      @behaviors = [:clickable, :draggable]
    end
   
  end
  
  class Controller
    include Grandpa::Controller::Base
    include Grandpa::Controller::Dragging    
  end
  
  class View
    
    include Grandpa::ViewBase
    
    def describe_view_of(model)
      # the following defines the view for the "base" default state of the square
      state :base do
        # an Animation can animate any number of objects that include the module Grandpa::Viewable
        has :component => Grandpa::Animation.new(
          [Rectangle.new(bind_to(model, :size), 0xff00ff00, bind_to(model, :location), :border => 5), 
            Rectangle.new(lambda { model.size+10 }, 0xffff0000, lambda { model.location-5 }, :border => 5),
              Rectangle.new(lambda { model.size+20 }, 0xff0000ff, lambda { model.location-10 }, :border => 5)],
               :speed => 15)
      end
      # this defines the view for the "mousedown" state
      state :mousedown do
        has :component => Grandpa::Animation.new(
          [Rectangle.new(bind_to(model, :size), 0xff0fff00, bind_to(model, :location), :border => 5), 
            Rectangle.new(lambda { model.size+10 }, 0xff000fff, lambda { model.location-5 }, :border => 5),
              Rectangle.new(lambda { model.size+20 }, 0xff00ff00, lambda { model.location-10 }, :border => 5)],
               :speed => 15)
      end
    end
    
  end
  
  def initialize
    @name = 'Dragging' # this becomes the window caption
    @controller = Controller.new(self)
    use_simple_pointer('examples/images/pointer.png')
    add_model(Model.new, :looks_like => View.new)
  end
  
end

app = DraggingApp.new
app.start!
