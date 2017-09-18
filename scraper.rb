# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

require 'nokogiri'
require 'open-uri'
require 'scraperwiki'

def fetch(url)
  p url
  Nokogiri::HTML.parse(open(url).read)
end

result = []
baseurl = 'http://www.kommunenokkelen.no'

begin
  front = fetch(baseurl)

  front.css('a').select { |e| e.text =~ /^\d\d/ }.map { |e| baseurl + e.attr('href') }.each do |county_url|
    county = fetch(county_url)

    county.css('a').select { |e| e.text.strip =~ /^\d{4}$/ }.map { |e| e.attr('href') }.each do |muni_url|
      muni = fetch(muni_url)
      muni_result = {}

      muni.css('#id_KNvisningstabell tr').map { |row|
        vals = row.css('td').map { |e| e.text.strip }
        vals[0] = vals[0].gsub(/[.\/-]/, "").downcase;

        unless vals[0].empty?
          muni_result[vals[0]] = vals[1]
        end
      }

      p muni_result

      if muni_result["kommunenr"]
        ScraperWiki.save_sqlite(["kommunenr"], muni_result)
      end
    end
  end
end
