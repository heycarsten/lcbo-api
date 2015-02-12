class RemoveZerosFromUpcSccInProducts < ActiveRecord::Migration
  def change
    execute 'UPDATE products SET upc = NULL WHERE upc = 0'
    execute 'UPDATE products SET scc = NULL WHERE scc = 0'
  end
end
