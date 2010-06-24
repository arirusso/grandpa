# including this gives Proc class a to_ruby method
module Grandpa::SerializableProcs
  
  def self.included(base)
    require 'rubygems'
    require 'parse_tree'
    require 'parse_tree_extensions'
    require 'ruby2ruby'
  end
  
end