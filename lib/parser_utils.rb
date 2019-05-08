# === COPYRIGHT:
# Copyright (c) Jason Adam Young
# === LICENSE:
# see LICENSE file

module ParserUtils
  def keyme(name,*others)
    ([name] + others).join(':').downcase.gsub(/[[:space:]]/, '')
  end
end
