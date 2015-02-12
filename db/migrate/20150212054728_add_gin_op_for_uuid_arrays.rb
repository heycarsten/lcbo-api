class AddGinOpForUuidArrays < ActiveRecord::Migration
  def up
    execute <<-SQL
DO $$
  BEGIN

    -- -----------------------------------------------------
    -- New Index Type for uuid[] columns
    --
    -- Create a GIN inverted index type for UUID array
    -- columns to enable quick comparisons
    -- https://coderwall.com/p/1b5eyq/index-for-uuid-array-data-type
    -- -----------------------------------------------------

    CREATE OPERATOR CLASS _uuid_ops DEFAULT FOR TYPE _uuid USING gin AS
      OPERATOR 1 &&(anyarray, anyarray),
      OPERATOR 2 @>(anyarray, anyarray),
      OPERATOR 3 <@(anyarray, anyarray),
      OPERATOR 4 =(anyarray, anyarray),
      FUNCTION 1 uuid_cmp(uuid, uuid),
      FUNCTION 2 ginarrayextract(anyarray, internal, internal),
      FUNCTION 3 ginqueryarrayextract(anyarray, internal, smallint, internal, internal, internal, internal),
      FUNCTION 4 ginarrayconsistent(internal, smallint, anyarray, integer, internal, internal, internal, internal),
      STORAGE uuid;

  EXCEPTION
    WHEN duplicate_object THEN
      RAISE NOTICE 'error: %', SQLERRM;
  END;
$$;
    SQL
  end

  def down
    execute "DROP OPERATOR CLASS IF EXISTS _uuid_ops USING gin CASCADE"
  end
end
