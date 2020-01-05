# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class SheetUploader < Shrine

    Attacher.validate do
        validate_extension %w[xls xlsx]
    end

    Attacher.metadata_attributes :updated_at => :updated_at

    add_metadata :signature do |io|
        calculate_signature(io, :md5)
    end
end
