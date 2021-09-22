ActiveAdmin.register_page "Apply" do  
  menu false
  
  breadcrumb do 
  	[
  		link_to('Expo', "/expo"), 
  		link_to('Online Applications', '/expo/admin/offerings'),
  		link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/apply/#{controller.instance_variable_get(:@offering).id}" )
  	]
  end

  controller do
  	
  	before_action :fetch_offering
  	before_action :fetch_apps

  	def manage
  		@phase = @offering.current_offering_admin_phase
  	end 

  	def list  
  	end

    # def awardees
  		
    # end

    def show
      @app = @offering.application_for_offerings.find params[:id]

      if params['section']
        respond_to do |format|
          format.html { return redirect_to :action => :show, :anchor => params[:section] }
          format.js   { return render :partial => "admin/apply/section/#{params[:section]}", :locals => { :admin_view => true } }
        end
      end
    end

  	private
  
    def fetch_offering
        if params[:offering]
          @offering = Offering.find params[:offering]
          require_user_unit @offering.unit
        end
    end

    def fetch_apps
      @apps ||= @offering.application_for_offerings
    end
	  
  end 
  
  sidebar "Quick Access", only: [:list, :show, :manage] do

  end 
  sidebar "Filter", only: [:list, :show, :manage] do
      
  end


end