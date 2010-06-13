module Grandpa::ViewBase
  
  class Subview 
    
    include Grandpa::ViewBase

    def initialize(proc)
      @my_proc = proc
      @states = {}
    end
    
    def describe_view_of(model)
      @my_proc.call(self,model)
    end

  end
  
  include Grandpa
  include Grandpa::Geom
  
  attr_accessor :states, :components, :label
  
  def bind_to(obj, property)
    lambda { obj.send(property) }
  end
  
  def state(name)
    @states = {} if @states.nil?
    @states[name] = yield
  end
  
  def has_label(*args, &block)
    always_on = args.first[:always_on] unless args.nil? or args.first.nil? or args.first[:always_on].nil? or !args.first[:always_on]
    @states.values.each do |state| 
      state.label = { :block => block, :always_on => always_on }
    end
  end
  
  def describe(name, &proc)
    @components = {} if @components.nil?
    @components[name] = Subview.new(proc)    
  end
  
  def subview(name, view)
    @components = {} if @components.nil?
    @components[name] = view
  end
  
  def main(view, opts = {})
    model = opts[:use]
    view.describe_view_of(model) unless model.nil?
    @states = view.states
    @components = view.components
  end
  
  def has(args)
    Grandpa::VisibleState.new(args)
  end
  
  def is(state)
    state
  end
  
end

class Grandpa::View
  include Grandpa::ViewBase
end
