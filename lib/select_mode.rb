module Grandpa::SelectMode
    
  module Base

    attr_accessor :deselect_on_clicked_background
    alias_method :deselect_on_clicked_background?, :deselect_on_clicked_background
    
  end
 
  class Single
    
    #mod
    include Base
    
    def initialize
      @deselect_on_clicked_background = true
    end
    
    def handle_mousedown(models, selection)
      to_select = models.find_all {|model| model.behavior.selectable? }
      mark_selected(to_select, selection) unless to_select.empty?
    end
    
    private
    
    def mark_selected(to_select, previous_selection)
      double_click = (to_select.map { |item| previous_selection.include?(item) }.include?(true) and to_select.length.eql?(1))
      unless double_click
        previous_selection.each { |model| model.behavior.deselect.call(:model => model) }
        previous_selection.clear
      end
      to_select.each { |model| model.behavior.select_proc.call(:model => model, :selection => previous_selection) }
      previous_selection << to_select
      previous_selection.flatten!.uniq!
    end
    
  end
  
  class Multi
    
    #mod
    include Base
    
    def initialize
      @deselect_on_clicked_background = false
    end
    
    def handle_mousedown(models, selection)
      to_select = models.find_all { |model| model.behavior.selectable? }
      to_select.each { |model| model.behavior.select.call(:model => model, :selection => selection) }
      selection << to_select
      selection.flatten!.uniq!
    end    
    
  end

end

