class ShrineConversion < ActiveRecord::Migration[5.2]
  def up
    ## uploads
    # dump all upload data
    execute("TRUNCATE table uploads RESTART IDENTITY;")

    # shrine data
    add_column(:uploads, :archive_data, :jsonb)
    add_column(:uploads, :archive_size, :int)
    add_column(:uploads, :archive_updated_at, :timestamp)

    # clear out paperclip columns
    remove_column(:uploads, :archivefile_file_name)
    remove_column(:uploads, :archivefile_file_size)
    remove_column(:uploads, :archivefile_content_type)
    remove_column(:uploads, :archivefile_updated_at)

    ## stat sheets
    # dump all upload data
    execute("TRUNCATE table stat_sheets RESTART IDENTITY;")

    # shrine data
    add_column(:stat_sheets, :sheet_data, :jsonb)
    add_column(:stat_sheets, :sheet_updated_at, :timestamp)

    # clear out paperclip columns
    remove_column(:stat_sheets, :datafile_file_name)
    remove_column(:stat_sheets, :datafile_file_size)
    remove_column(:stat_sheets, :datafile_content_type)
    remove_column(:stat_sheets, :datafile_updated_at)

  end
end
