class ModelHelpText < HelpText
  stampable
  validates_presence_of :object_type, :attribute_name
  
  # Returns the corresponding ModelHelpText for the information that's passed to it.
  # 
  # * Pass a model name constant to get all ModelHelpTexts for that model.
  # * Pass a model name constant and attribute name (in symbol form) to get the help text just for that attribute.
  # * Pass an object and attribute name (in symbol form) and the model name will be inferred.
  # 
  # If there is no matching help text for the arguments passed, +nil+ is returned.
  def self.for(*args)
    if args.size == 1 && args.first.is_a?(Class)
      results = ModelHelpText.where(object_type: args.first.to_s).to_a
    else
      model_type = args[0].is_a?(Class) ? args[0] : args[0].class
      results = ModelHelpText.find_by(object_type: model_type.to_s, attribute_name: args[1].to_s)
    end
    results.present? ? results : nil
  end

  def self.set(model_name, attribute_name, values)
    model_class = model_name.constantize
    obj = ModelHelpText.for(model_class, attribute_name) || ModelHelpText.new(object_type: model_class.to_s, attribute_name: attribute_name)
    
    #Rails.logger.debug "Before update: #{obj.inspect}"
    obj.assign_attributes(values)
    #Rails.logger.debug "After update: #{obj.inspect}"    
    if obj.save
      #Rails.logger.debug "Saved successfully."
    else
      Rails.logger.error "Save failed: #{obj.errors.full_messages.join(', ')}"
    end
  end
  
end