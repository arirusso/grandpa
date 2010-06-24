require 'grandpa'

# this simple example displays a set of squares. when the big square is clicked on, one of the others is deleted
class CallbackApp
  
  include Grandpa::Mvc
  
  class Green < Grandpa::ViewFactory 
    
    def describe_views_of(model)
      # the following defines the view for the "base" default state of the square
      state :base do
        # bind_to lends itself towards better performance than lambda { model.x }
        has :component => Rectangle.new(bind_to(model, :size), 0xff00ff00, bind_to(model, :location), :border => 5) 
      end
      # this defines the view for the "mousedown" state
      state :mousedown do
        has :component => Rectangle.new(lambda { model.size+6 }, 0xff000fff, lambda { model.location-3 }, :border => 5)
      end
    end
    
  end
  
  class Red < Grandpa::ViewFactory
    
    def describe_views_of(model)
      state :base do
        has :component => Rectangle.new(bind_to(model, :size), 0xffff0000, bind_to(model, :location), :border => 5) 
      end
    end
    
  end
  
  def initialize
    
    @controller = Grandpa::BasicController.new(self)
    
    use_simple_pointer('examples/images/pointer.png')
    
    big_model = Grandpa::BasicModel.new(:size => Point[50,50], :location => Point[50,50], :behavior => :clickable)
    big_model.behavior.mousedown = lambda { |args| models.last.destroy! }
    add_model(big_model, :looks_like => Green.new) 
    
    5.times do |i|
      model = Grandpa::BasicModel.new(:size => Point[20,20], :location => Point[500, ((i+1)*20)+(i*20)])
      add_model(model, :looks_like => Red.new)
    end
    
  end
  
end

app = CallbackApp.new
app.start!
