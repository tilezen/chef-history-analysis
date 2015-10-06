require 'open-uri'
require 'json'
require 'csv'

input_uri = ARGV[0]
cities = JSON.parse(open(input_uri).read)

top_100 = CSV.parse(<<CSV
"new york, new york","1,092",699,1
"london, england",763,522,1
"paris, france",586,420,1
"mumbai, india",581,195,1
"beijing, china",545,315,1
"moscow, russia",540,342,1
"san francisco bay, california",507,361,1
"hong kong, china",504,258,1
"chicago, illinois",495,310,1
singapore,489,267,1
"shanghai, china",473,248,1
"melbourne, australia",457,282,1
"berlin, germany",447,307,1
"tokyo, japan",404,235,1
"aarhus, denmark",399,299,1
"sydney, australia",396,215,1
"los angeles, california",386,268,1
"rome, italy",381,232,1
"barcelona, spain",358,195,1
"amsterdam, netherlands",351,229,1
"seoul, south korea",335,164,1
"dc baltimore, maryland",332,209,1
"boston, massachusetts",326,210,1
"istanbul, turkey",323,182,1
"san francisco, california",310,206,1
"madrid, spain",282,186,1
"saint petersburg, russia",277,158,1
"seattle, washington",272,169,1
"dubai, abu dhabi",259,142,1
"hamburg, germany",246,141,1
"toronto, canada",239,173,1
"munich, germany",235,157,1
"sao paulo, brazil",230,140,1
"montreal, canada",226,152,1
"bengaluru, india",225,161,1
"mexico city, mexico",225,142,1
"milan, italy",221,156,1
"detroit, michigan",219,110,1
"dublin, ireland",218,130,1
"vancouver, canada",210,123,1
"rio de janeiro, brazil",204,112,1
"new delhi, india",201,140,1
"lisbon, portugal",188,97,1
"kyiv, ukraine",187,126,1
"portland, oregon",187,132,1
"krakow, poland",186,106,1
"warsaw, poland",184,122,1
"venice, italy",182,115,1
"copenhagen, denmark",178,110,1
"atlanta, georgia",176,134,1
"stockholm, sweden",175,105,1
"athens, greece",167,84,1
"prague, czech republic",166,114,1
"jakarta, indonesia",161,86,1
"philadelphia, pennsylvania",161,105,1
"miami, florida",160,94,1
"houston, texas",159,88,1
"minsk, belarus",159,95,1
"abidjan, ivory coast",157,113,1
"denver boulder, colorado",152,113,1
"frankfurt, germany",152,114,1
"vienna bratislava, austria",152,122,1
"austin, texas",151,100,1
"cape town, south africa",151,71,1
"bangkok, thailand",148,87,1
"brisbane, australia",148,86,1
"san diego tijuana, mexico",148,93,1
"perth, australia",141,83,1
"chennai, india",138,86,1
"brussels, belgium",136,108,1
"dallas, texas",136,107,1
"oslo, norway",136,79,1
"buenos aires, argentina",131,83,1
"adelaide, australia",128,71,1
"cairo, egypt",128,75,1
"johannesburg, south africa",126,69,1
"brasilia, brazil",124,72,1
"new orleans, louisiana",122,78,1
"albany, new york",120,86,1
"accra, ghana",119,69,1
"manila, philippines",118,46,1
"san jose, california",112,59,1
"zurich, switzerland",112,79,1
"bucharest, romania",110,73,1
"hyderabad, india",109,79,1
"kuala lumpur, malaysia",109,75,1
"santiago, chile",108,78,1
"tel aviv, israel",108,65,1
"bogota, colombia",107,74,1
"edinburgh, scotland",107,64,1
"lagos, nigeria",107,44,1
"taipei, taiwan",107,58,1
"budapest, hungary",105,81,1
"abuja, nigeria",104,67,1
"lyon, france",104,82,1
"florence, italy",103,63,1
"manchester, england",103,61,1
"ottawa, canada",102,70,1
"naples, italy",101,49,1
"auckland, new zealand",100,62,1
CSV
)

cities_lookup = Hash.new

cities['regions'].each do |rname, region|
  region['cities'].each do |cname, city|
    bbox = ['left', 'top', 'right', 'bottom'].map { |dir| city['bbox'][dir].to_f }
    name = cname.downcase.gsub(/[^a-z]+/, "_")
    cities_lookup[name] = bbox
  end
end

top_100.shuffle.each_slice(17) do |slice|
  data = Hash.new
  slice.each do |name, total, unique, interesting|
    normalised_name = name.downcase.gsub(/[^a-z]+/, "_")

    unless cities_lookup[normalised_name].nil?
      data[normalised_name] = cities_lookup[normalised_name]
    end
  end

  puts JSON.dump({'history_splitter' => { 'locations' => data } })
end
