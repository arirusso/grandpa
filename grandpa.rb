begin
  require 'rubygems'
rescue LoadError
  
end
require 'gosu'

require 'forwardable'
require 'singleton'

module Grandpa
  module Geom
  end
end

require 'lib/viewable'

# geom classes
require 'lib/geom/line'
require 'lib/geom/rectangle'
require 'lib/geom/cyclic_polygon'
require 'lib/geom/triangle'
require 'lib/geom/point'

require 'lib/animation'
require 'lib/background'
require 'lib/image'

require 'lib/controller'
require 'lib/core_extensions'
require 'lib/model_base'
require 'lib/model_container'
require 'lib/select_modes'
require 'lib/tween'
require 'lib/ui_state'
require 'lib/view_set'
require 'lib/visible_state'
require 'lib/visible_state_manager'
require 'lib/window'

require 'lib/simple_pointer'

require 'lib/mvc'
require 'lib/app'

p "Grandpa running with ruby #{RUBY_VERSION}"