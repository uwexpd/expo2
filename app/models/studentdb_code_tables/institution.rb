# Institution Codes
class Institution < StudentInfo
  self.table_name = "sec.sys_tbl_02_ed_inst_info"
  self.primary_key = :table_key

  def <=>(o)
    name <=> o.name rescue 0
  end
  
  def id
    read_attribute(:table_key).to_i
  end
  
  def self.find_by_table_key(key)
    padded_key = key.to_s.rjust(6, '0')
    where(table_key: padded_key).first
  end

  def name
    college_names = {
      "THE EVERGREEN ST COLL" => "The Evergreen State College",
      "NORTH SEATTLE CC"      => "North Seattle College",
      "SEATTLE CENTRAL CC"    => "Seattle Central Community College",
      "SEATTLE PACIFIC UNIV"  => "Seattle Pacific University",
      "SEATTLE UNIV"          => "Seattle University",
      "CLEVELAND STATE UNIV"  => "Cleveland State University",
      "EARLHAM COLL"          => "Earlham College",
      "JOHN JAY C CRIM JUST"  => "John Jay College of Criminal Justice",
      "UNIV NTHRN COLORADO"   => "University of Northern Colorado",
      "WASH STATE UNIV"       => "Washington State University",
      "UNIV WISC OSHKOSH"     => "University Wisconsin, Oshkosh",
      "PORTLAND ST UNIV"      => "Portland State University",
      "WESTERN WASH UNIV"     => "Western Washington University",
      "UNIV CALIF DAVIS"      => "University of California, Davis",
      "EVERETT COMM COLL"     => "Everett Community College",
      "BOISE ST UNIV"         => "Boise State University",
      "EDMONDS COMM COLL"     => "Edmonds Community College",
      "UNIV OF PUGET SOUND"   => "University of Puget Sound",
      "WAYNE STATE UNIV "     => "Wayne State University",
      "CALIFORNIA STATE UNIV:EAST BAY" => "California State University, East Bay",
      "UNIV ST THOMAS"        => "University of St. Thomas",
      "EASTERN WASHINGTON UNIV" => "Eastern Washington University",
      "HERITAGE COLLEGE"      => "Heritage College",
      "WHITMAN COLL"          => "Whitman College",
      "MINNESOTA STATE UNIV"  => "Minnesota State University",
      "ST MARYS UNIVERSITY"   => "St. Mary's University",
      "CENTRAL WASHINGTON UNIV" => "Central Washington University",
      "PACIFIC LUTHERAN UNIV" => "Pacific Lutheran University",
      "UNIV NORTH TEXAS"      => "University of North Texas",
      "CALIF ST UNIV DOM HL"  => "California State University, Dominguez Hills",
      "UNIV WISC RIVER FLS"   => "University of Wisconsin, River Falls",
      "MONTANA STATE UNIV"    => "Montana State University",
      "ARKANSAS ST UNIV"      => "Arkansas State University",
      "UNIV NTHRN IOWA"       => "University of Northern Iowa",
      "UNIV OF WASHINGTON"    => "University of Washington",
      "SOUTH SEATTLE CC"      => "South Seattle College",
      "UNIV OF NEW HAMPSHIRE" => "University of New Hampshire",
      "UNIV NEVADA LAS VEGA"  => "University of Nevada Las Vegas",
      "BEMIDJI ST UNIV"       => "Bemidji State University",
      "KENT STATE UNIV"       => "Kent State University",
      "QUEENS COLL NY"        => "Queens College of New York",
      "LOYOLA UNIV CHICAGO"   => "Loyola University Chicago",
      "CALIFORNIA ST UNIV: FULLERTON" => "California State University Fullerton",
      "CAL ST U SACRAMENTO"   => "California State University, Sacramento",
      "BLOOMFIELD COLL"       => "Bloomfield College",
      "SHORELINE COMM COLL"   => "Shoreline Community College",
      "UNIV OF UTAH"          => "University of Utah",
      "NORTH DAKOTA ST UNIV"  => "North Dakota State University",
      "UNIV OF VICTORIA"      => "University of Victoria"
                   
      }
    college_names[institution_name.strip] || institution_name.strip.titleize
  end
  
end
