class ChangeProductsPackageUnitVolumeInMillilitersToInteger < ActiveRecord::Migration
  def change
    change_column :products, :package_unit_volume_in_milliliters, :integer
  end
end
