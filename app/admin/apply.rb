  ActiveAdmin.register_page "Apply" do
  menu false
  
  breadcrumb do 
  	[
  		link_to('Expo', "/expo"), 
  		link_to('Online Applications', '/expo/admin/offerings'),
      link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}" )
  	]
  end

  controller do    
  	before_action :fetch_offering
  	before_action :fetch_apps, only: [:list]
    before_action :fatch_phase, only: [:task, :mass_update]
    # before_action :fetch_task, only: [:task, :mass_update]

  	def manage
  		@phase = @offering.current_offering_admin_phase
  	end 

  	def list
  	end

    # def awardees
  		
    # end

    def phase      
      @phase = @offering.phases.find params[:id]
      @page_title = "#{@phase.name}"
    end

    def task      
      @task = @phase.tasks.find(params[:id]) 
      # [TODO] make this work: add_breadcrumb "#{@phase.name}", admin_apply_phase_path(@offering, @phase)
    end

    def mass_update
      if params[:tasks]
        params[:tasks].each do |task,values|          
          @phase.tasks.find(task).update(complete: values[:complete])
        end
      end      
      respond_to do |format|
        format.js 
        # { render :partial => "admin/apply/phases/tasks/sidebar_task", :collection => @phase.tasks }
      end
    end

    def show
      @app = @offering.application_for_offerings.find params[:id]

      if params['section']
        respond_to do |format|
          format.html { return redirect_to :action => :show, :anchor => params[:section] }
          format.js   { return render :partial => "admin/apply/section/#{params[:section]}", :locals => { :admin_view => true } }
        end
      end
    end

    def view
      @app = ApplicationForOffering.find params[:id]

      if params[:file]
        file = @app.files.find(params[:file]).file
        file_path = "#{Rails.root}/files/application_file/file/#{@app.id}/#{file.filename}"
      elsif params[:mentor]
        mentor_id = params[:mentor]
        letter = @app.mentors.find(mentor_id).letter
        file_path = "#{Rails.root}/files/application_mentor/letter/#{mentor_id}/#{letter.filename}"
    end
      send_file(file_path, x_sendfile: true) unless file_path.nil?
    end

  	protected
  
    def fetch_offering
        if params[:offering]
          @offering = Offering.find params[:offering]
          require_user_unit @offering.unit
        end
    end

    def fetch_apps
      @apps ||= @offering.application_for_offerings.sort_by(&:fullname)
    end

    def fatch_phase
      @phase = @offering.phases.find(params[:phase])
    end
	  
  end 
  
  sidebar "Quick Access", only: [:list, :show, :manage, :phase, :task] do

  end 
  sidebar "Filter", only: [:list, :show, :manage] do
      
  end
  sidebar "Task for this Phase", only: [:phase, :task] do
    render "admin/apply/phases/tasks/sidebar/tasks" 
  end
  sidebar "Switch to this Phase", only: [:phase] do
      
  end


end