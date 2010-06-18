require 'observer'
# change observer method name to update_observed
module Observable
  
  attr_accessor :observer_peers

  def add_observer(observer)
    @observer_peers = [] unless defined? @observer_peers
    @observer_peers.push observer
  end
  
  def notify_observers(model, signal, data = {})
    if defined? @observer_state and @observer_state
      if defined? @observer_peers
        for i in @observer_peers.dup
          i.send('update_observed', model, signal, data)
        end
      end
      @observer_state = false
    end
  end
  
end