module ActiveAdmin
  module Views
    class Footer < Component

      def build
        super :id => "footer"

        div do                                                                   
          small "Copyright © 2007–#{Date.today.year} University of Washington.
					Problems, questions or suggestions? Send an e-mail to #{Rails.configuration.constants['system_help_email']}."
        end
      end

    end
  end
end