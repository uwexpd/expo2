namespace :scholarships do
  namespace :db do |ns|
     
     %i(drop create setup migrate rollback seed version).each do |task_name|
           task task_name do
             Rake::Task["db:#{task_name}"].invoke
           end
     end
     
     namespace :schema do
        task :load do
           Rake::Task["db:schema:load"].invoke
        end

        task :dump do
           Rake::Task["db:schema:dump"].invoke
        end        
     end
     
     namespace :test do
        task :prepare do
             Rake::Task["db:test:prepare"].invoke
        end
     end
         
     # append and prepend proper tasks to all the tasks defined here above
     ns.tasks.each do |task|
        task.enhance ["scholarships:set_custom_config"] do
          Rake::Task["scholarships:revert_to_original_config"].invoke
        end
     end
     
  end # end of db namespace
        
  task :set_custom_config do
     # save current vars
     @original_config = {
       env_schema: ENV['SCHEMA'],
       config: Rails.application.config.dup
     }

     # set config variables for custom database
     ENV['SCHEMA'] = "db_scholarships/schema.rb"
     Rails.application.config.paths['db'] = ["db_scholarships"]
     Rails.application.config.paths['db/migrate'] = ["db_scholarships/migrate"]
     Rails.application.config.paths['db/seeds'] = ["db_scholarships/seeds.rb"]
     Rails.application.config.paths['config/database'] = ["config/database_scholarships.yml"]
end   
     
  task :revert_to_original_config do
     # reset config variables to original values
     ENV['SCHEMA'] = @original_config[:env_schema]
     Rails.application.config = @original_config[:config]
end   
                        

end