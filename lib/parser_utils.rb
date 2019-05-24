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
    if(string =~ %r{Jackson\.A})
      string.gsub(%r{Jackson\.A},'Jackson,A')
    elsif(string =~ %r{Kennedy\.A})
      string.gsub(%r{Kennedy\.A},'Kennedy,A')
    else
      string
    end
  end

end
