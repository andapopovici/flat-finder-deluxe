def get_zoopla(notify: false)
  p "Getting Zoopla..."
  doc = HTTParty.get("https://www.zoopla.co.uk/to-rent/property/edinburgh/?beds_min=2&include_shared_accommodation=false&price_frequency=per_month&price_max=1000&q=Edinburgh&results_sort=newest_listings&search_source=home")

  @parsed = Nokogiri::HTML(doc)
  ids = @parsed.xpath('//ul[contains(@class, "listing-results")]/li/@data-listing-id')
  dates = @parsed.xpath('//small[contains(text(),"Listed on")]').children.map {|el|
    suffix = el.text.strip.sub("Listed on \n ", "")
    return_idx = suffix.index("\n")

    suffix[0..return_idx-1]
  }

  p dates

  fetched_ids = ids.map { |id| id.value }

  saved_ids = load_saved_ids

  p "Loading saved ids"
  p saved_ids

  new_ids = newly_added_ids(fetched_ids, saved_ids)

  if notify && new_ids
    results = new_ids.map { |id| "https://www.zoopla.co.uk/to-rent/details/#{id}" }
    Mailer.new.send(results)
  end

  if new_ids
    p "Saving #{new_ids.length} new results"
    save_ids(new_ids)
  end
end

def load_saved_ids
  ids = []
  if File.exist?("saves/zoopla.txt")
    File.readlines("saves/zoopla.txt").each do |line|
      ids << line.strip
    end
  end

  ids
end

def save_ids(ids)
  Dir.mkdir("saves") unless File.exists?("saves")

  open("saves/zoopla.txt", "a") { |f|
    ids.each do |id|
      f.puts id
    end
  }
end

def newly_added_ids(fetched_ids, saved_ids)
  new_ids = []
  fetched_ids.each do |fetched_id|
    found = false
    saved_ids.each do |saved_id|
      if fetched_id == saved_id
        found = true
        break
      end
    end

    if !found
      new_ids << fetched_id
    end
  end

  new_ids
end
