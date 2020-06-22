class AddUploadState < ActiveRecord::Migration[5.2]
  def change
    add_column(:uploads,:state,:string)
  end
end
