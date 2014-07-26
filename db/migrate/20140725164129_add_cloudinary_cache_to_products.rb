class AddCloudinaryCacheToProducts < ActiveRecord::Migration
  def change
    add_column :products, :cloudinary_cache, :text
  end
end
