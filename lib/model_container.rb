class Grandpa::ModelContainer < Array
  
 def move_by(amount)
   each { |child| child.move_by(amount) }
 end
    
 def location=(location)
   each { |child| child.location=(location) }
 end

 def destroy!
   each { |child| child.destroy! }
 end
 
 def dragging_enabled=(bool)
   each { |child| child.dragging_enabled = bool }
 end
 
 def with_name(name)
   find { |model| model.name.to_s.eql?(name.to_s) }
 end
  
end