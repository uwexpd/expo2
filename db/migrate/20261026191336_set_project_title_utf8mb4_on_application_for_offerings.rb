class SetProjectTitleUtf8mb4OnApplicationForOfferings < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      ALTER TABLE application_for_offerings
        MODIFY COLUMN project_title VARCHAR(255)
        CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
        NULL DEFAULT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Project titles may now contain characters that utf8mb3 cannot store"
  end
end
