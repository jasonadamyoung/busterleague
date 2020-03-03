class ShrineConversion < ActiveRecord::Migration[5.2]
  def up
    ## uploads
    # dump all upload data
    execute("TRUNCATE table uploads RESTART IDENTITY;")

    # shrine data
    add_column(:uploads, :archive_data, :jsonb)
    add_column(:uploads, :archive_size, :int)
    add_column(:uploads, :archive_signature, :string)

    add_index(:uploads, ["archive_signature"], name: "archve_signature_ndx", unique: true)


    add_column(:uploads, :archive_updated_at, :timestamp)

    # clear out paperclip columns
    remove_column(:uploads, :archivefile_file_name)
    remove_column(:uploads, :archivefile_file_size)
    remove_column(:uploads, :archivefile_content_type)
    remove_column(:uploads, :archivefile_updated_at)
    remove_column(:uploads, :archivefile_fingerprint)

    ## stat sheets
    # dump all upload data
    execute("TRUNCATE table stat_sheets RESTART IDENTITY;")

    # shrine data
    add_column(:stat_sheets, :sheet_data, :jsonb)
    add_column(:stat_sheets, :sheet_size, :int)
    add_column(:stat_sheets, :sheet_signature, :string)
    add_index(:stat_sheets, ["sheet_signature"], name: "sheet_signature_ndx", unique: true)

    # clear out paperclip columns
    remove_column(:stat_sheets, :datafile_file_name)
    remove_column(:stat_sheets, :datafile_file_size)
    remove_column(:stat_sheets, :datafile_content_type)
    remove_column(:stat_sheets, :datafile_updated_at)
    remove_column(:stat_sheets, :datafile_fingerprint)

  end
end
