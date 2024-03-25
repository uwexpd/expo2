module StringHelper
  extend ActiveSupport::Concern

  BROKEN_FIXED_MAP = {
    'â€“' => '—',
    'â€”' => '–',
    'â€˜' => '‘',
    'â€™' => '’',
    'â€œ' => '“',
    'â€' => '”'    
  }

  included do    
    before_save :fix_strings
  end

  def fix_strings
    puts "debug => fix_strings"
    self.attributes.each do |attr_name, value|
      if value.is_a?(String)
        BROKEN_FIXED_MAP.each do |broken, fixed|
          value.gsub!(broken, fixed)
        end
        self[attr_name] = value
      end
    end
  end
end
