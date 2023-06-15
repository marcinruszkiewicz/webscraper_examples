# frozen_string_literal: true

require "json"
require "vessel"

class CommunityResults < Vessel::Cargo
  domain "community.testeveonline.com"

  def parse
    page_title = at_css("#content h1.content-title")&.text
    matches = []

    css(".at-results table tr").each do |row|
      team1 = row.at_css("td:nth-child(3) span:nth-child(1)")
      team2 = row.at_css("td:nth-child(3) span:nth-child(3)")
      next unless team1 && team2

      winner = team1.attribute("class") == "winner" ? team1 : team2

      matches << {
        team1: team1.text,
        team2: team2.text,
        winner: winner.text
      }
    end

    full_results = {
      name: page_title.sub("Alliance Tournament ", "AT").sub("Results", "").strip,
      matches: matches
    }

    yield full_results
  end
end

results = File.read("winners.json")
json = JSON.parse(results)

urls = []
json.each do |tournament|
  next unless tournament["results"] =~ /community\.testeveonline\.com/
  urls << tournament["results"]
end

match_results = []
CommunityResults.run(start_urls: urls){ |a| match_results << a }

json_results = match_results.to_json
File.open("match_results.json", "w") do |f|
  f.write json_results
end
