module Rubyipmi
  class VERSION
    MAJOR = 0
    MINOR = 7
    PATCH = 1
    PRE   = :pre

    def self.to_s
      [MAJOR, MINOR, PATCH, PRE].compact.join('.')
    end
  end
end
