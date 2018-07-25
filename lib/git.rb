require "google_drive"

session = GoogleDrive::Session.from_config("config.json")

# Gets list of remote files.
# session.files.each do |file|
#   p file.title
# end

# Uploads a local file.
session.upload_from_file("../db/convertcsv.csv", "convertcsv.csv", convert: false)

# Downloads to a local file.
# file = session.file_by_title("hello.txt")
# file.download_to_file("/path/to/hello.txt")

# # Updates content of the remote file.
# file.update_from_file("/path/to/hello.txt")