class AddFullTextIndexesToProducersAndCategories < ActiveRecord::Migration[5.0]
  def up
    add_column :categories, :name_vectors, :tsvector
    add_column :producers,  :name_vectors, :tsvector

    add_index :categories, :name_vectors, using: :gin
    add_index :producers,  :name_vectors, using: :gin

    execute <<-SQL
      UPDATE "categories" SET "name_vectors" = (to_tsvector('simple', unaccent(coalesce("name"::text, ''))));
      UPDATE "producers"  SET "name_vectors" = (to_tsvector('simple', unaccent(coalesce("name"::text, ''))));
    SQL

    execute <<-SQL
      CREATE TRIGGER categories_tsvectorupdate BEFORE INSERT OR UPDATE ON "categories" FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger("name_vectors", 'pg_catalog.simple', "name");

      CREATE TRIGGER producers_tsvectorupdate BEFORE INSERT OR UPDATE ON "producers" FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger("name_vectors", 'pg_catalog.simple', "name");
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER categories_tsvectorupdate ON "categories";
      DROP TRIGGER producers_tsvectorupdate ON "producers";
    SQL

    remove_index :producers,  :name_vectors
    remove_index :categories, :name_vectors

    remove_column :producers,  :name_vectors
    remove_column :categories, :name_vectors
  end
end
