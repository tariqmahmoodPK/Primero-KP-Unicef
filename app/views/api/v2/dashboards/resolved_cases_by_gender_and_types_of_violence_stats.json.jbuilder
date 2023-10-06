# TODO Update the referencing comments after properly updating the files
# resolved_cases_by_gender_and_types_of_violence_stats
# Closed Cases by Sex and Protection Concern

json.data do
  @stats.each do |key, value|
    #? Why are we checking for this ?
    if key.to_s.eql?("permission")
      json.set!(key, value)
    else
      concerns = {}
      value.each do |key1, value2|

        key1_str = key1.to_s # Convert the symbol to a string
        matching_data = @lookup_values.find { |data| data["id"] == key1_str }

        if matching_data
          key1_en = matching_data["display_text"]["en"]
          concerns[key1_en] = value2
        end
      end
      json.set!(key, concerns)
    end
  end
end