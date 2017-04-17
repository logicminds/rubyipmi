require "observer"

module Rubyipmi
  class ObservableHash < Hash
    include Observable

    # this method will merge the hash and then notify all observers, if any
    def merge_notify!(newhash)
      merge!(newhash)
      changed
      notify_observers(self)
    end

    def delete_notify(del)
      delete(del)
      notify_observers(self)
    end
  end
end
