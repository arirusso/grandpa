module Grandpa::Model
  
  class UiBehavior
    
    attr_accessor :drag_available,
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
      @mousedown ||= lambda { |args| args[:model].state_change(:mousedown!) }
      @mouseup ||= lambda { |args| args[:model].state_change(:end_mousedown!) }
    end
    
    def make_resizable!
      @resize_available ||= lambda { |args| }
      @resize ||= lambda { |args| }
      @resize_release ||= lambda { |args| }    
    end
    
    def make_selectable!
      @select_available ||= lambda { |args| }
      @select ||= lambda { |args| args[:model].state_change(:select!) }
      @deselect ||= lambda { |args| args[:model].state_change(:de_select!) }
    end
    
    def make_draggable!
      @drag_available ||= lambda { |args| }
      @drag ||= lambda do |args|
        args[:model].state_change(:dragging!)
        args[:model].move_by(args[:amount])
      end
      @drag_release ||= lambda { |args| args[:model].state_change(:end_dragging!) }
      #@dragging_enabled = true
    end
    
    def initialize(options = {})
      
      # the ||= nil's are just for show
      @drag_available ||= nil
      @drag ||= nil
      @drag_release ||= nil
      @mousedown ||= nil
      @mouseup ||= nil
      @mouseover ||= lambda { |args| args[:model].state_change(:hover!) }
      @mouseout ||= lambda { |args| args[:model].state_change(:no_hover!) }
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