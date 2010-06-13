class Grandpa::Window < Gosu::Window
  
  # namespaces
  include Grandpa
  include Grandpa::Geom
  include Gosu::Button
  
  include Observable 
  attr_accessor :m, :md, :fonts
  alias_method :mouse_position, :m
  alias_method :mouse_move_amount, :md
              
  def initialize(app,*a)
    @m, @md = Point.new(0,0), Point.new(0,0)
    @app = app
    super(*a)
    init_fonts
  end
  
  def draw
    @app.draw_background
    @app.draw_views
  end
  
  def update
    @md = Point[mouse_x - @m.x, mouse_y - @m.y] 
    @m = Point[mouse_x, mouse_y]
    register(:mouse_move, @md) unless @md.eql?(Point[0.0,0.0])
    @app.update
  end
  
  def init_fonts
    @fonts = {}
    (8..32).each do |height|
      @fonts[height] = Gosu::Font.new(self, Gosu::default_font_name, height)
    end
    @font = get_font(18)
  end
  
  def get_font size
    @fonts[size]
  end
 
  def register(name, data = nil)
    changed
    notify_observers(self, name, data)
  end
  
  def button_down(id)
    case id
      when MsLeft then register(:left_mousedown)
      when MsRight then register(:right_mousedown)
      when KbUp then register(:keydown_up)
    end
  end
  
  def button_up(id)
    case id 
      when MsLeft then register(:left_mouseup)
      when MsRight then register(:right_mouseup)
    end
  end  

end