require "adwords_scraper/version"
require "mechanize"
require_relative "clearbit_search"



module AdwordsScraper
    def self.test
      "inside test"
    end

    def self.start(keyword)
      doc = fetch_serp(keyword)
      scrape_serp(doc)
    end

    def self.fetch_serp(keyword)
      url = query_url(keyword)
      agent = Mechanize.new
      # It's best to mimic a common browser or else Google may not display all ad
      # formats
      agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.874.121 Safari/535.2'
      agent.get url
    end

    def self.query_url(keyword)
      'http://www.google.com/search?q='+ keyword.gsub(" ", "+")
    end

    def self.scrape_serp(doc)
      container = {}
      selectors = {}

      selectors['top'] = ".ads-ad"  # the only selector needed for 2017 design

      # selectors['top'] = "#tads .ads-ad"
      # selectors['right'] = "#mbEnd li" # .vsra (old)
      # selectors['bottom'] = "#tadsb li"

      selectors.each do |location, selector|
        candidate = doc.search(selector)
        if !candidate.search('h3').empty? && candidate.size < 10 # two validations
          container[location] = candidate
        end
      end
      ad_container = []

      container.each do |location, ad_docs|
        ad_docs.each do |ad_doc|
          next unless ad_doc.search('img').empty? # skipping ads that have an image attribute
          begin
            p = ad_doc.search('a').first['id'].match(/\d/)[0]
          rescue => e
            binding.pry
          end
          position = "#{location}:#{p}"
          # ad_container << [ position, parse_ad(ad_doc) ]
          ad_container << [ parse_ad(ad_doc) ] #removed position

        end
      end
      ad_container
    end

    def self.parse_ad(doc)
      container = {}
      desc = ''
      d = doc.search('.ads-creative').first.children

      d.each do |i|
        if i.name == 'br'
          desc = desc + ' '
        else
          desc = desc + i.text
        end
      end

      container['title'] = doc.search('h3').text # doc title text
      container['description'] = desc.gsub('  ', ' ')
      container['targeturl'] = doc.search('h3 > a ~ a').attr('href').value # doc title text
      container['displayurl'] = doc.search('.ads-visurl > cite').text # display URL
      if doc.search('._r2b').text != ""
        container['phone'] = doc.search('._r2b').text
      else
        container['phone'] = doc.search('._xnd').text
      end
      container['address'] = doc.search('._vnd').text
      container['domain'] = URI.parse(container['targeturl']).host
      domain = container['domain']
      company = clearbit_serch_by_domain(domain)
      container['company_name'] = company.name





    container
  end
end
