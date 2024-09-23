module DeepDup
  def self.prepended(base)
    base.class_eval do
      alias_method :clone_without_deep_dup, :dup
      alias_method :dup, :clone_with_deep_dup
    end
  end

  # Clones an ActiveRecord model.
  # if passed the :include option, it will deep clone the given associations
  # if passed the :except option, it won't clone the given attributes (on parent object or ANY child objects)
  #
  # === Usage:
  #   pirate.clone :except => :name
  #   pirate.clone :except => [:name, :nick_name]
  #   pirate.clone :include => :mateys
  #   pirate.clone :include => [:mateys, :treasures]
  #   pirate.clone :include => {:treasures => :gold_pieces}
  #   pirate.clone :include => [:mateys, {:treasures => :gold_pieces}]
  #
  def clone_with_deep_dup(options = {})
    begin
      transaction do
        kopy = clone_without_deep_dup          
        kopy.save

        if options[:except]
          Array(options[:except]).each do |attribute|
            kopy.write_attribute(attribute, self.class.column_defaults[attribute.to_s]) if kopy.has_attribute?(attribute)
          end
        end

        if options[:include]
          Array(options[:include]).each do |association, deep_associations|
            if association.is_a?(Hash)
              deep_associations = association.values.first
              association = association.keys.first
            end
            opts = deep_associations.blank? ? {} : { include: deep_associations }
            opts[:except] = options[:except] if options[:except].present?
            kopy.send("#{association}=", self.send(association).map { |i| i.dup(opts) })
          end
        end

        kopy.save
        kopy
      end    
    rescue => e
      Rails.logger.error("An error occurred: #{e.message}")      
      false
    end
  end

end
