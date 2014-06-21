class SpeedUpFullTextSearch < ActiveRecord::Migration
  def change
    add_column :products, :tag_vectors, :tsvector
    add_column :stores,   :tag_vectors, :tsvector

    add_index :products, :tag_vectors, using: :gin
    add_index :stores,   :tag_vectors, using: :gin

    execute <<-SQL
      UPDATE "products" SET "tag_vectors" = (to_tsvector('simple', unaccent(coalesce("tags"::text, ''))));
      UPDATE "stores"   SET "tag_vectors" = (to_tsvector('simple', unaccent(coalesce("tags"::text, ''))));
    SQL

    execute <<-SQL
      CREATE TRIGGER products_tsvectorupdate BEFORE INSERT OR UPDATE ON "products" FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger("tag_vectors", 'pg_catalog.simple', "tags");

      CREATE TRIGGER stores_tsvectorupdate BEFORE INSERT OR UPDATE ON "stores" FOR EACH ROW EXECUTE PROCEDURE
        tsvector_update_trigger("tag_vectors", 'pg_catalog.simple', "tags");
    SQL
  end
end
