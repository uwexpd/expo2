# monkey patch https://dev.to/ayushn21/applying-monkey-patches-in-rails-1bj1
module CoreExtensions
  module String
    
    #is_numeric? "545"  #true,  is_numeric? "2aa"  #false
    def is_numeric?
       self.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end

    def is_int?
      Integer(self) && true rescue false
    end

    def is_float?
      Float(self) && true rescue false
    end
    
  end
end