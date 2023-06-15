# frozen_string_literal: true

require "open-uri"
require "nokogiri"
require "json"

url = "https://wiki.eveuniversity.org/Alliance_Tournament"
html = URI.parse(url).open
doc = Nokogiri::HTML(html)

results = []

doc.css("table.wikitable tr").each do |row|
  winners_name = row.css("td:nth-child(3)").text.strip
  tournament_name = row.css("td:nth-child(1)").text.strip
  next if winners_name.empty?
  next if tournament_name.empty?

  tournament_year = row.css("td:nth-child(2)").xpath('text()').text.strip
  tournament_yc_year = row.css("td:nth-child(2) span").text.strip

  bracket_link = row.css("td:nth-child(5) a:contains('Bracket')").attr("href")&.value
  results_link = row.css("td:nth-child(5) a:contains('Results')").attr("href")&.value

  tournament = {
    name: tournament_name,
    year: tournament_year,
    yc: tournament_yc_year,
    winners: winners_name,
    bracket: bracket_link,
    results: results_link
  }

  results << tournament
end

json = results.to_json

File.open("winners.json", "w") do |f|
  f.write json
end
