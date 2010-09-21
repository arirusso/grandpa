class Grandpa::Geom::Point
  
  attr_reader :x, :y
  
  alias_method :width, :x
  alias_method :height, :y
  
  def self.[](x,y)
    self.new(x,y)
  end
  
  def +(amount)
    amount = ensure_point(amount)
    self.class.new(@x+amount.x,@y+amount.y)
  end
  
  def -(amount)
    amount = ensure_point(amount)
    self.class.new(@x-amount.x,@y-amount.y)
  end
  
  def /(amount)
    amount = ensure_point(amount)
    self.class.new(@x/amount.x,@y/amount.y)
  end
  
  def *(amount)
    amount = ensure_point(amount)
    self.class.new(@x*amount.x,@y*amount.y)
  end
  
  def initialize(x,y,z=nil)
    @x, @y = x, y
  end
  
  def eql?(another)
    @x.eql?(another.x) and @y.eql?(another.y)
  end
  
  private
  
  def ensure_point(amount)
    return amount if amount.kind_of?(self.class)
    self.class.new(amount,amount)
  end
  
end