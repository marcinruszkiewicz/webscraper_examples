# frozen_string_literal: true

require "open-uri"
require "json"
require "tanakai"

class BracketsSpider < Tanakai::Base
  @name = "brackets_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://challonge.com/atxviii", "https://challonge.com/atxvii", "https://challonge.com/AllianceTournamentXVI"]
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    before_request: { delay: 4..7 }
  }

  def parse(response, url:, data: {})
    page_title = response.css(".tournament-banner-header h4")&.text

    matches = []

    response.xpath("//g[contains(@class, 'match')]").each do |match|
      teams = match.xpath(".//text[contains(@class, 'match--player-name')]").map(&:text)
      winner = match.at_xpath(".//text[contains(@class, 'match--player-name')][contains(@class, '-winner')]").text

      matches << {
        team1: teams.first,
        team2: teams.second,
        winner: winner
      }
    end

    full_results = {
      name: page_title.sub("Alliance Tournament ", "AT").strip,
      matches: matches
    }

    save_to "bracket_results.json", full_results, format: :json
  end
end

BracketsSpider.crawl!
