class Scraper
  attr_accessor :page, :xpath_email, :xpath_townhalls, :num_townhalls, :array_townhall

  def initialize(url, xpath_townhalls, xpath_email)
    @page = init_url(url)
    @xpath_townhalls = xpath_townhalls
    @xpath_email = xpath_email
    @num_townhalls = page.xpath(xpath_townhalls).length
    @array_townhall = Array.new
  end

  def init_url(url)
    print "Chargement de la page Web..."
    page = Nokogiri::HTML(open(url))
    page
  end

  def get_email(link_page_email, n)
    page_email = init_url(link_page_email)
    puts "Page Web #{n+1}/#{@num_townhalls} chargée !"
    return page_email.xpath(@xpath_email).text
  end

  def creation_array
    (0..10).each do |n|
      hash_tmp = Hash.new
      townhall = @page.xpath(@xpath_townhalls)[n].text.downcase.gsub(/[\s]/, '_')
      link = @page.xpath(@xpath_townhalls)[n]['href'].gsub(/^[\.]/, '')
      link = "https://annuaire-des-mairies.com#{link}"
      hash_tmp[townhall] = get_email(link, n)

      @array_townhall << hash_tmp
      puts "Le hash #{hash_tmp} a été ajouté dans le tableau array_mairies"
    end
  end

  def stock_array_json
    File.open('array_townhall.json','w') do |f|
      f.write(@array_townhall.to_json)
    end
  end

  def retrieve_array_json
    json = File.read('array_townhall.json')
    obj = JSON.parse(json)
  end

  def stock_array_google
    # Creates a session
    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title("test")
    worksheet = spreadsheet.worksheets.first

    (0..@array_townhall.length - 1).each do |x|
      worksheet.insert_rows((worksheet.num_rows)+1, [ ["#{@array_townhall[x].keys.to_json}", "#{@array_townhall[x].values.to_json}"] ])
    end
    worksheet.save
  end

  def retrieve_array_google
    session = GoogleDrive::Session.from_service_account_key("client_secret.json")
    spreadsheet = session.spreadsheet_by_title("test")
    worksheet = spreadsheet.worksheets.first
    hash_tmp = Hash.new
    array = Array.new

    worksheet.rows.first(worksheet.num_rows).each { |row| @array_townhall << row.first(2)}
  end

  def stock_array_csv
    CSV.open("emails.csv", "w") do |csv|
      csv << @array_townhall
    end
  end

  def retrieve_array_csv
    @array_townhall = CSV.read("emails.csv")
  end
end
