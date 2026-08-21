# The parent class for all objects that come from the UWSDB.  StudentInfo establishes a connection to the UWSDB database and sets the primary key for all child classes to match UWSDB's primary key ("system_key")
class StudentInfo < ActiveRecord::Base

  self.abstract_class = true # this says that this class does not have an associated table in the DB
  establish_connection :edwpub # any sub-classes will initiate a connection to our ODBC DSN when loaded

  # Set some options to work with the UWSDB tables properly
  #self.pluralize_table_names = false  # don't do this because it seems to be a global change, not just on StudentInfo models
  self.primary_key = "system_key"
  
  # Since some UWSDB tables use the reserved word +class+ as a column name, this will prevent ActiveRecord from trying to create
  # an instance method out of that column. In order to access the +class+ attribute on such models, you'll need to use foo[:class]
  # of read_attribute(:class).
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == 'class'
      super
    end

    # Override first/last to avoid a SQL Server bug where the sqlserver adapter
    # duplicates ORDER BY columns when a composite primary key is present,
    # causing: "A column has been specified more than once in the order by list."
    # Using reorder() clears any existing order before applying ours, preventing duplication.

    def first(limit = nil)
      limit ? reorder(pk_order(:asc)).limit(limit).to_a : reorder(pk_order(:asc)).limit(1).first
    end

    def last(limit = nil)
      limit ? reorder(pk_order(:desc)).first(limit) : reorder(pk_order(:desc)).first
    end

    private

    # Builds an ordered hash from the model's primary key columns.
    # Works for both single and composite primary keys.
    # direction: :asc for first, :desc for last
    def pk_order(direction)
      Array(primary_key).each_with_object({}) { |col, h| h[col.to_sym] = direction }
    end
  end

end
