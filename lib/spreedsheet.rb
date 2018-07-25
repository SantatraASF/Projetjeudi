require "google_drive"
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'



    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1VV-q4FrBPuVC3fT04O7EGbpkRkqtwauQLgN3L8w_OYY").worksheets[0]
    #recuperation des données
    ws[1, 1] = "Ville"
    ws[1, 2] = "Email"

    

    ws.save

    s.rows 

 



  