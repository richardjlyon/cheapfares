# coding: utf-8
require 'nokogiri'
require 'watir'
require 'json'

module Cheapfares
  # Cheapfares::Trainline scrapes thetrainline.com for fare information.
  # HTML is obtained via Watir.
  # @example
  #   require 'cheapfares'
  #
  #   t = Cheapfares::Trainline.new
  #   t.fetchPricesLFromSite(outward_date:outward_date, origin: origin, destination: destination)
  #   puts t.prices
  # @api public
  class Trainline

    # Base of the search string
    ROOT_URL = 'https://www.thetrainline.com/farefinder/BestFares.aspx?'
    # Location of a cached version of the webpage, for testing
    CACHE_FILEPATH = File.join(File.dirname(__FILE__), '/cache/trainline.html')

    # Initialise an instance of [Trainline]
    def initialize
      @travel_prices = Hash.new { |hash, key| hash[key] = Hash.new() }
    end

    # Utility function during testing to avoid hitting thetrainline.com
    # @return [Nokogiri::HTML]
    def fetchPricesFromCache
      @origin = 'EUS'
      @destination = 'EDB'
      @outward_date = Date.new(2017, 7, 24)
      @html = File.open(CACHE_FILEPATH) { |f| Nokogiri::HTML(f) }
    end

    # Get html of price information
    # @param [String] origin Starting station (as three letter code)
    # @param [String] destination Destination station (as three letter code)
    # @param [Date] Start Date of price information
    def fetchPricesLFromSite(origin:, destination:, outward_date:)
      @origin = origin
      @destination = destination
      @outward_date = outward_date
      b = Watir::Browser.new :chrome
      b.goto searchstring
      @html = Nokogiri::HTML.parse(b.html)
    end

    # It's a valid Nokogiri Document
    # @return [Boolean]
    def ok?
      return @html.is_a?(Nokogiri::HTML::Document)
    end

    # Parse the HTML to extract price information
    # @param [Date] date
    # @return [Hash] { date => {"early_morning"=>127.0, "morning"=>100.5, "afternoon"=>84.0, "evening"=>126.0}}
    def prices(date:nil)
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
          prices_in_bands[date][timeband_names[index]] = price
          date = date + 1
        end
      end
      return prices_in_bands
    end

    # Calculate the total of all the timebands in a given day
    # @param [Date] date The date to Calculate
    # @return [Float] total The total price
    def total_of_prices(date:nil)
      all_prices = prices(date:date)
      return all_prices[date].values.inject { |a, b| a + b }
    end

    private

    # Build the thetrainline.com searchstring
    # @return [String] e.g. ROOT_URL?orig=EUS&dest=EDB&out=20170807&rtn=20170813
    def searchstring
      return ROOT_URL+ "orig=#{@origin}&dest=#{@destination}&out=#{@outward_date.strftime("%Y%m%d")}"
    end

    # Extract the price, return 'nil' if none
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
