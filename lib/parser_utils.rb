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

  def cell_text(cell)
    text = cell.text.strip
    if(text == '&nbsp')
      ''
    else
      text
    end
  end

  def label_translation(label)
    case label.downcase
    when '1b'
      'h1b'
    when '2b'
      'h2b'
    when '3b'
      'h3b'
    else
      label
    end
  end

  def name_transforms(name)
    transformed = name.dup
    # all because of Jones(R)
    transformed.gsub!(%r{[\(\)]},'')
    transformed
  end
  
  def more_mass_name_nonsense(string)
    # replace all "Jackson.A" strings with "Jackson,A"
    # I mean, seriously WTF
    if(string =~ %r{Jackson\.A})
      string.gsub(%r{Jackson\.A},'Jackson,A')
    else
      string
    end
  end

end
