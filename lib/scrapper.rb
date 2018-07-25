require "google_drive"
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

def get_the_email_of_a_townhal_from_its_webpage(url)
    page = Nokogiri::HTML(open(url))
    email = page.css('tr.tr-last td')[7].text
    return email
end


urls = "http://annuaire-des-mairies.com/val-d-oise.html"
def get_all_the_urls_of_val_doise_townhalls(urls)
    page = Nokogiri::HTML(open(urls))


    source = "http://annuaire-des-mairies.com/"

    ville = {}

    links = page.css("a.lientxt")
    links.each do |link|
        
        lien = link['href']
        nom_ville = link.text

        link_updated = lien.gsub(/(\.\/)/, "")
        last_link = source + link_updated

        ville[nom_ville] = last_link  
    end
  
    return ville
end

tab_ville = get_all_the_urls_of_val_doise_townhalls(urls)
def get_email_par_ville(tableau_hash)
    tab_ville = []
    tab_email = []
    tableau_hash.each do |ville, url|
        tab_ville << ville
        tab_email << get_the_email_of_a_townhal_from_its_webpage(url)
    end

    ville = Hash[tab_ville.zip(tab_email)]
    return ville
end

def save_json(tab_ville)
    emails_tab= get_email_par_ville(tab_ville)
    File.open("../db/emails.json","a")do |f|
        f.write(emails_tab.to_json)
    end
end
puts "Debut d'écriture de fichier json"
save_json(tab_ville)
puts "Fin d'ecriture de fichier json"
def spreadsheet(tableau_hash)
    emails_tab= get_email_par_ville(tableau_hash)
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1VV-q4FrBPuVC3fT04O7EGbpkRkqtwauQLgN3L8w_OYY").worksheets[0]
    #recuperation des données
    ws[1, 1] = "Ville"
    ws[1, 2] = "Email"

    i = 2 # car la premiere ligne contient les titres, les infos commencent à la ligne 2
    emails_tab.each do |ville, email|
        ws[i, 1] = ville
        ws[i, 2] = email
    
        ws.save # permet de modifier et d'enregistrer le spreadsheet
        i += 1 # permet de passesr à la ligne suivante
    end
end
puts "Début d'écriture du fichier spreedsheet"
spreadsheet(tab_ville)
puts "Fin d'écriture du spreedsheet"
