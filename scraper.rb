require 'pp'
require 'nokogiri'
require 'open-uri'
# require 'scraperwiki'

def fetch(url)
  p url
  Nokogiri::HTML.parse(open(url).read)
end

result = []
baseurl = 'http://www.kommunenokkelen.no'

begin
  front = fetch("#{baseurl}/home")

  front.css('a').select { |e| e.text =~ /^\d+$/ }.map { |e| e.attr('href') }.each do |muni_url|
    muni = fetch(muni_url)
    muni_result = {}

    muni.css('#id_KNvisningstabell tr').map { |row|
      vals = row.css('td').map { |e| e.text.strip }
      vals[0] = vals[0].gsub(/[.\/-]/, "").downcase;

      unless vals[0].empty?
        muni_result[vals[0]] = vals[1]
      end
    }

    pp muni_result

    if muni_result["kommunenr"]
      # ScraperWiki.save_sqlite(["kommunenr"], muni_result)
    end
  end
end
