class AddInvisibleToPageAndNextPageToQuesitonOption < ActiveRecord::Migration[5.2]
  def change
    add_column :offering_pages, :invisible, :boolean    
    add_column :offering_question_options, :next_page_id, :integer
  end
end
