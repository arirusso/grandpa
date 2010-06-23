module Grandpa::Model
  
  # I may merge this back in to Model::Base at some point
  class UiBehavior
    
    attr_writer :drag_available,
      :drag,
      :drag_release,
      :mousedown,
      :mouseup,
      :mouseover,
      :mouseout,
      :resize_available,
      :resize,
      :resize_release,
      :select_available,
      :select,
      :deselect
    
    def add_behaviors!(behaviors)
      behaviors.kind_of?(Array) ? behaviors.each { |behavior| add_behavior!(behavior) } : add_behavior!(behaviors)
    end
    
    def add_behavior!(behavior)
      case behavior
        when :clickable then make_clickable!
        when :draggable then make_draggable!
        when :resizable then make_resizable!
        when :selectable then make_selectable!
      end
    end
    
    def resizable?
      !@resize.nil?
    end
    
    def draggable?
      !@drag.nil? and !@drag_release.nil?
    end
    
    def clickable?
      !@mousedown.nil?
    end
    
    def selectable?
      !@select.nil? and !@deselect.nil?
    end
    
    def drop_receiver?
      !@drop_receive.nil?
    end
    
    def make_clickable!
      @mousedown ||= lambda { |args| }
      @mouseup ||= lambda { |args| }
    end
    
    def make_resizable!
      @resize_available ||= lambda { |args| }
      @resize ||= lambda { |args| }
      @resize_release ||= lambda { |args| }    
    end
    
    def make_selectable!
      @select_available ||= lambda { |args| }
      @select ||= lambda { |args|  }
      @deselect ||= lambda { |args| }
    end
    
    def make_draggable!
      @drag_available ||= lambda { |args| }
      @drag ||= lambda do |args|
        args[:model].move_by(args[:amount])
      end
      @drag_release ||= lambda { |args| }
      #@dragging_enabled = true
    end
    
    # intercepts the callback and triggers the state change signal automatically when a callback is called
    def method_missing(m, *args, &block)
      if public_methods.include?("#{m}=") # checks to see if the property is public
        @model.state_change(m.to_sym)
        return instance_variable_get("@#{m}")
      end
    end
    
    def initialize(model, options = {})
      @model = model
      # the ||= nil's are just for show
      @drag_available ||= nil
      @drag ||= nil
      @drag_release ||= nil
      @mousedown ||= nil
      @mouseup ||= nil
      @mouseover ||= lambda { |args| }
      @mouseout ||= lambda { |args| }
      @resize_available ||= nil
      @resize ||= nil
      @resize_release ||= nil
      @select_available ||= nil
      @select ||= nil
      @deselect ||= nil   
      #
      add_behaviors!(options[:behaviors]) unless options[:behaviors].nil?
      add_behaviors!(options[:behavior]) unless options[:behavior].nil?
    end
    
  end
end