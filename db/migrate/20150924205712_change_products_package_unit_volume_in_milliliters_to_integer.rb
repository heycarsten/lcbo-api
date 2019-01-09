class ChangeProductsPackageUnitVolumeInMillilitersToInteger < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :package_unit_volume_in_milliliters, :integer
  end
end
