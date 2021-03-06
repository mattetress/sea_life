class SeaLife::Scraper

  BASE_URL = "https://oceana.org"

  def self.scrape_categories #Scrapes oceana and returns array of categories
    categories = []
    doc = Nokogiri::HTML(open(BASE_URL + "/marine-life"))

    doc.css("article.animal-tile").each do |item|
      category = {}
      category[:url] = item.css("div.overlay a").attribute("href").value
      category[:name] = item.css("div.copy h1").text
      categories << category unless category[:name] == "Marine Science and Ecosystems"
    end

    categories
  end

  def self.scrape_animals(category)
    doc = Nokogiri::HTML(open(BASE_URL + category.url))

    doc.css("article").each do |animal|
      animal_info = {}
      animal_info[:category] = category
      animal_info[:name] = animal.css("div.copy h1").text
      animal_info[:url] = animal.css("div.overlay a").attribute("href").value
      SeaLife::Animal.new(animal_info)
    end
  end

  def self.scrape_animal_info(animal)
    doc = Nokogiri::HTML(open(BASE_URL + animal.url))

    animal_info = {}
    animal_info[:scientific_name] = doc.css("section.subpage-header div p").text
    animal_info[:short_desc] = doc.css("div.animal-description-contain p").text
    animal_info[:longer_desc] = ""

    doc.css("section.animal-secondary div.flex-item-2 p").each do |paragraph|
      break if paragraph.text == "Additional Resources:"
      animal_info[:longer_desc] += "\n\n #{paragraph.text}"
    end

    i = 0
    while i < doc.css("div.animal-details-side h2").size - 1 do
      info_cat = doc.css("div.animal-details-side h2")[i].text.strip.downcase
      info = doc.css("div.animal-details-side p")[i].text.strip

      case info_cat
      when "ecosystem/habitat"
        animal_info[:habitat] = info
      when "feeding habits"
        animal_info[:habits] = info
      when "conservation status"
        animal_info[:status] = info
      else
        animal_info[info_cat.to_sym] = info
      end

      i += 1
    end
    
    animal.add_info(animal_info)
  end

end
