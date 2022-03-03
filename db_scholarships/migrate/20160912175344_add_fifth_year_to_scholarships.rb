class AddFifthYearToScholarships < ActiveRecord::Migration
  def change    
    add_column :scholarships, :fifth_year, :boolean
    add_column :scholarships, :lgbtqi_community, :boolean
  end
end
