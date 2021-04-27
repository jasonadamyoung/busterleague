# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module ParserUtils

  ConverterEncoding = Encoding.find("UTF-8")

  CONVERTERS  = {
    integer:   lambda { |f|
      Integer(f.encode(ConverterEncoding)) rescue f
    },
    float:     lambda { |f|
      Float(f.encode(ConverterEncoding)) rescue f
    }
  }

  def convert_numeric(value)
    returnvalue = value
    [:integer,:float].each do |convertertype|
      converter = CONVERTERS[convertertype]
      returnvalue = converter[value]
      break unless returnvalue.is_a?(String)
    end
    returnvalue
  end

  def keyme(name,*others)
    Digest::MD5.hexdigest(([name] + others).join(':').downcase.gsub(/[[:space:]]/, ''))
  end

  def convert_field(field,prefix = '')
    converted_field = field.downcase
    converted_field = converted_field.downcase.gsub('/','_per_')
    converted_field = converted_field.gsub('%','_percent')
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
    when 'inn'
      'ip'
    else
      label
    end
  end

  def name_fixer(name)
    case name
    when 'Valeri delosSantos'
      'Valerio de los Santos'
    when 'Paul LoDuca'
      'Paul Lo Duca'
    else
      name
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
    bullshit_regex_list = []
    bullshit_regex_list << %r{Jackson\.A}
    bullshit_regex_list << %r{Kennedy\.A}
    bullshit_regex_list << %r{Gurriel\.L}
    bullshit_regex_list << %r{Gurriel\.Y}

    new_string = string.dup

    if(string =~ Regexp.union(bullshit_regex_list))
      # replace them all for now until I think of a better way.
      new_string.gsub!(%r{Jackson\.A},'Jackson,A')
      new_string.gsub!(%r{Kennedy\.A},'Kennedy,A')
      new_string.gsub!(%r{Gurriel\.L},'Gurriel,L')
      new_string.gsub!(%r{Gurriel\.Y},'Gurriel,Y')
      new_string
    else
      string
    end
  end

end
