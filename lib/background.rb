class Grandpa::Background
  
  attr_accessor :images
  
  def initialize(image, options = {})
    @mask = options[:mask] || 0xff333333
    @zorder = options[:zorder] || 0
    @filename = image 
  end
  
  def init(gosu_window)
    @image = Gosu::Image.new(gosu_window, @filename, true)
  end
  
  def draw(gosu_window)
    y,x=0,0
    while y <= gosu_window.height
      x=0
      while x <= gosu_window.width
        @image.draw(x, y, @zorder, 1,1,@mask)
        x += @image.width
      end
      y += @image.height
    end    
  end
  
end