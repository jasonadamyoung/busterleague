# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

class ArchiveUploader < Shrine

    Attacher.validate do
        validate_mime_type %w[application/zip]
    end

    Attacher.metadata_attributes :size => :size, :signature => :signature

    add_metadata :signature do |io|
        calculate_signature(io, :md5)
    end
end
