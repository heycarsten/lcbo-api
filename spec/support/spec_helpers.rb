module SpecHelpers
  def clean_database
    DB.tables.
      reject { |table| table == :schema_info }.
      each   { |table| DB[table].delete }
  end
end
