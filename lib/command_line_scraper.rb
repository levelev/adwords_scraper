require_relative 'adwords_scraper'

loop do
  p "Enter keyword" # For testing
  print "> "
  keyword = gets.chomp
  break if keyword == ""
  results = AdwordsScraper.start(keyword)
  p "#{results.size} Ads found for keyword: #{keyword}"

  results.each_with_index do |result, index|
    p "Ad \# #{index +  1}"
    p result
  end
end
