require "google_drive"
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'gmail'




def get_the_email_of_a_townhal_from_its_webpage(url)
    page = Nokogiri::HTML(open(url))
    email = page.css('tr.tr-last td')[7].text
    return email
end


urls = "http://annuaire-des-mairies.com/lozere.html"
def get_all_the_urls(urls)
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

tab_ville = get_all_the_urls(urls)
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
    File.open("email.json","a")do |f|
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
   #recuperation des données
   ws[1, 1] = "Département"
   ws[1, 2] = "Commune"
   ws[1,3]  = "E-mail"
   
   departement ="Lozère"
   i = 2 # car la premiere ligne contient les titres, les infos commencent à la ligne 2
   emails_tab.each do |ville, email|
       ws[i,1]= departement
       ws[i, 2] = ville
       ws[i, 3] = email
        ws.save # permet de modifier et d'enregistrer le spreadsheet
        i += 1 # permet de passesr à la ligne suivante
    end
end
puts "Début d'écriture du fichier spreedsheet"
spreadsheet(tab_ville)
puts "Fin d'écriture du spreedsheet"

def mailler(i)
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1VV-q4FrBPuVC3fT04O7EGbpkRkqtwauQLgN3L8w_OYY").worksheets[0]
    commune = ws[i, 2]
    mail = ws[i, 3]
    Gmail.connect("maya.ramaroson@gmail.com", "") do |gmail|
        gmail.deliver do
          to "#{mail}"
          subject "Promotion de The Hacking Project"
        html_part do 
          content_type 'text/html; charset=UTF-8'
          body "<p>Ceci vous informeras de la formation The hacking project </p>
          <br>
          <p>Je suis élève à The Hacking Project, une formation au code gratuite, sans locaux, sans sélection, sans restriction géographique.</p>
          <p> La pédagogie de ntore école est celle du peer-learning, où nous travaillons par petits groupes sur des projets concrets qui font apprendre le code.</p>
          <p> Le projet du jour est d'envoyer (avec du codage) des emails aux mairies pour qu'ils nous aident à faire de The Hacking Project un nouveau format d'éducation pour tous.</p>
          <p>Déjà 500 personnes sont passées par The Hacking Project. Est-ce que la mairie de #{commune} veut changer le monde avec nous ?
            </br>
          <p>Charles, co-fondateur de The Hacking Project pourra répondre à toutes vos questions : 06.95.46.60.80</p>
           "
            end
        end
    end
end
def tout_les_mails
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("1VV-q4FrBPuVC3fT04O7EGbpkRkqtwauQLgN3L8w_OYY").worksheets[0]
  i = 2 
  until ws[i, 1] == ws[186,1] do
    mailler(i) #permet d'envoyer l'email au destinataire i
    i += 1 #permet de passer a la ligne suivante
  end
end
tout_les_mails