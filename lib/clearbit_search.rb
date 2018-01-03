require 'clearbit'
require_relative "../keys.rb"


Clearbit.key = CLEARBIT_KEY

# # Command line
# p "Enter domain"
# domain = gets.chomp
# company = Clearbit::Enrichment::Company.find(domain: domain)
# p company.site.phoneNumbers.class


def clearbit_serch_by_domain(domain)
  company = Clearbit::Enrichment::Company.find(domain: domain)
  return company
end
