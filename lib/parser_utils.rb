# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module ParserUtils
  def keyme(name,*others)
    Digest::MD5.hexdigest(([name] + others).join(':').downcase.gsub(/[[:space:]]/, ''))
  end

  def convert_field(field,prefix = '')
    converted_field = field.downcase.gsub('/','_per_')
    if(['name','team','p','age'].include?(converted_field))
      # don't prefix repeated string fields
      converted_field
    else
      "#{prefix}#{converted_field}"
    end

  end

end
