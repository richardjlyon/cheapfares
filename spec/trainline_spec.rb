require 'spec_helper'
require 'date'

describe Cheapfares::Trainline do

  before :all do
    @trainline = Cheapfares::Trainline.new
  end

  it 'has a version number' do
    expect(Cheapfares::VERSION).not_to be nil
  end

  it 'fetches html from cache' do
    @trainline = Cheapfares::Trainline.new
    @trainline.fetchPricesFromCache
    expect(@trainline.ok?).to eq true
  end

  it 'gets prices for a day' do
    @trainline = Cheapfares::Trainline.new
    @trainline.fetchPricesFromCache
    outward_date = Date.new(2017, 7, 24)
    prices = @trainline.prices(date: outward_date)
    expect(prices[outward_date-3].values).to eq [127.0, 100.5, 84.0, 126.0]
    expect(prices[outward_date-2].values).to eq [68.0, 71.0, 58.0, nil]
    expect(prices[outward_date-1].values).to eq [71.0, 71.0, 71.0, 60.0]
    expect(prices[outward_date].values).to   eq [71.0, 84.0, 58.0, 55.0]
    expect(prices[outward_date+1].values).to eq [58.0, 71.0, 58.0, 60.0]
    expect(prices[outward_date+2].values).to eq [58.0, 58.0, 50.5, 60.0]
    expect(prices[outward_date+3].values).to eq [58.0, 71.0, 71.0, 60.0]
  end

  it 'gets a price for a timeband' do
    @trainline = Cheapfares::Trainline.new
    @trainline.fetchPricesFromCache
    outward_date = Date.new(2017, 7, 21)
    prices = @trainline.prices(date: outward_date)
    expect(prices[outward_date]['early_morning']).to eq 127.0
  end

  it 'gets the sum of timeband prices for a day' do
    @trainline = Cheapfares::Trainline.new
    @trainline.fetchPricesFromCache
    outward_date = Date.new(2017, 7, 21)
    total_of_prices = @trainline.total_of_prices(date: outward_date)
    expect(total_of_prices).to eq 437.5
  end

  it 'gets live data' do
    @trainline = Cheapfares::Trainline.new
    @trainline.fetchPricesLFromSite(outward_date: Date.today + 4, origin: 'EUS', destination: 'EDB')
    expect(@trainline.ok?).to eq true
  end

end
