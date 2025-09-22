ActiveAdmin.register PopulationCondition, as: 'conditions' do
  menu false
  belongs_to :population

  permit_params :population_id, :attribute_name, :eval_method, :value, :should_destroy, :skip_validations

  controller do
      before_action :fetch_population

      def create
        @condition = @population.conditions.new(condition_params)

        respond_to do |format|
          if @condition.save
            flash[:notice] = "Successfully created condition."            
            format.js { render 'admin/queries/conditions/create' }
            format.html { redirect_to edit_admin_query_conditions_path(@population, @condition) }            
          else            
            format.js { render 'admin/queries/conditions/create' }
            format.html { render :action => "new" }            
          end
        end
      end

      def destroy
        @condition = @population.conditions.find(params[:id])
        @condition.destroy
        
        respond_to do |format|
          format.html { redirect_to(admin_query_conditions_path(@population, @condition)) }
          format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
        end
      end

      def refresh_dropdowns
        return unless params[:population] && params[:population][:condition_attributes]

        if params[:id] == 'new'
          first_params = params[:population][:condition_attributes].values.first || {}
          @condition = @population.conditions.new(first_params.permit(:attribute_name, :eval_method, :value, :skip_validations, :should_destroy))
        else
          @condition = @population.conditions.find(params[:id])
          @condition.update(condition_attributes_params) if params[:population].present?
        end

        respond_to { |format| format.js { render 'admin/queries/conditions/refresh_dropdowns' } }
      end

      protected

      def fetch_population
        @population = Population.find params[:query_id]        
      end

      private

      def condition_params
        params.require(:condition).permit(:eval_method, :value, :skip_validations)
      end

      def condition_attributes_params
        params.require(:population)
              .require(:condition_attributes)
              .require(@condition.id.to_s)
              .permit(:id, :attribute_name, :eval_method, :value, :skip_validations, :should_destroy)
      end
    
  end


  index do
    column :population
    column :attribute_name
    column :eval_method
    column :value
    actions defaults: true do |condition|
      # You can add custom links here if needed
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :population
      f.input :attribute_name, as: :select, collection: f.object.possible_attributes, include_blank: true
      f.input :eval_method, as: :select, collection: f.object.possible_eval_methods, include_blank: true
      f.input :value, as: :string
    end

    f.actions
  end

  show do
    attributes_table do
      row :population
      row :attribute_name
      row :eval_method
      row :value
    end
  end
end
