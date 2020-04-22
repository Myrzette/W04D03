# frozen_string_literal: true

require 'bundler'
Bundler.require
require 'csv'

require_relative 'lib/scraper'

def main

  test = Scraper.new('https://annuaire-des-mairies.com/val-d-oise.html', '//a[@class="lientxt"]', '/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]')
  #puts test.num_townhalls
  test.creation_array
  #test.stock_array
  #puts test.retrieve_array
  #test.stock_array_google
  test.stock_array_csv
  #puts test.array_townhall
  puts test.retrieve_array_csv
end

main