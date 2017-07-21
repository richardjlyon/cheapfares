# coding: utf-8
require 'nokogiri'
require 'watir'
require 'json'

module Cheapfares
  class Trainline

    ROOT_URL = 'https://www.thetrainline.com/farefinder/BestFares.aspx?'
    CACHE_FILEPATH = '/Users/richardlyon/Library/Mobile Documents/com~apple~CloudDocs/Documents/Personal/Coding/Ruby/development/rjl-cheapfares/cache/trainline_oneway.html'

    def initialize
      @travel_prices = Hash.new { |hash, key| hash[key] = Hash.new() }
    end

    def fetchPricesFromCache
      @origin = 'EUS'
      @destination = 'EDB'
      @outward_date = Date.new(2017, 7, 24)
      @html = File.open(CACHE_FILEPATH) { |f| Nokogiri::HTML(f) }
    end

    def fetchPricesLFromSite(origin:, destination:, outward_date:)
      @origin = origin
      @destination = destination
      @outward_date = outward_date
      b = Watir::Browser.new :chrome
      b.goto searchstring
      @html = Nokogiri::HTML.parse(b.html)
    end

    def ok?
      return @html.is_a?(Nokogiri::HTML::Document)
    end

    def prices(date:nil)
      @travel_prices = get_prices(date:date)
      return @travel_prices
    end

    def total_of_prices(date:nil)
      all_prices = prices(date:date)
      return all_prices[date].values.inject { |a, b| a + b }
    end

    private

    def searchstring
      # e.g. ROOT_URL?orig=EUS&dest=EDB&out=20170807&rtn=20170813
      return ROOT_URL+ "orig=#{@origin}&dest=#{@destination}&out=#{@outward_date.strftime("%Y%m%d")}"
    end

    def get_prices(date:nil)
      # set up data structure e.g. price[date][timeband] = £73.00
      timeband_names = ['early_morning', 'morning', 'afternoon', 'evening']
      prices_in_bands = Hash.new { |hash, key| hash[key] = Hash.new() }

      price_table_html = @html.css("table#ctl00_Body_ctlOutboundWeekView_tblJourneys tbody")
      start_date = @outward_date - 3

      # extract prices from price table
      price_table_html.css("tr").each_with_index do |timeband_html, index|
        date = start_date
        timeband_html.css("td").each do |date_html|
          price = parse_price_from_html(date_html)
          # puts price
          prices_in_bands[date][timeband_names[index]] = price
          date = date + 1
        end
      end
      return prices_in_bands
    end

    def parse_price_from_html(html)
      price = html.text.gsub(/[^\d\.]/, '').to_f
      if price > 0
        return price
      else
        return nil
      end
    end
  end
end
