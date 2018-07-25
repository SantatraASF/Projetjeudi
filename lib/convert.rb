require 'csv' 
require 'json'

CSV.open("../db/email.csv", "w") do |csv| 
    #open new file for write 
    JSON.parse(File.open("../db/emails.json").read).each do |hash| 
        #open json to parse 
        csv << hash.values
        #write value to file 
    end 
end
