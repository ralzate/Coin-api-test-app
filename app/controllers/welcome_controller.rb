require 'time'

class WelcomeController < ApplicationController
  def index
    @crypto_prices = read_data_from_api
    coin_api = CoinApiService.new('E65472C4-138A-4385-AAA7-6F85B9E10447')

    @bitcoin_price = coin_api.get_current_price('BTC')
    @ethereum_price = coin_api.get_current_price('ETH')
    @cardano_price = coin_api.get_current_price('ADA')
  end

  def export
    return unless params[:commit].include?('Exportar')

    crypto_prices = {
      btc_price: params['bitcoin_price_export'],
      eth_price: params['ethereum_price_export'],
      ada_price: params['cardano_price_export']
    }

    format = export_format(params[:commit])
    export_file(make_content(crypto_prices), format)
  end

  private

  def read_data_from_api
    url_crypto_values = 'https://data.messari.io/api/v1/assets?fields=id,slug,symbol,metrics/market_data/price_usd'
    response = RestClient.get(url_crypto_values)
    result = JSON.parse(response.body)

    crypto_prices = {}
    result['data'].each do |asset|
      symbol = asset['symbol']
      price = asset['metrics']['market_data']['price_usd'].round(2)
      crypto_prices[symbol] = price
    end

    crypto_prices
  end

  def export_format(button)
    {
      'Exportar EXCEL' => 'xls',
      'Exportar CSV' => 'csv',
      'Exportar JSON' => 'json'
    }[button]
  end

  def export_file(content, format)
    time_now_formatted = Time.now.strftime("%H_%M_%S_%d-%h-%Y_UTC-0")
    file_name = "crypto_prices_#{time_now_formatted}.#{format}"

    send_data(
      content,
      type: "text/#{format}",
      disposition: 'attachment',
      filename: file_name
    )
  end

  def make_content(crypto_prices)
    content = "##ASSET##PRICE(USD)\n"
    crypto_prices.each_with_index do |(key, value), index|
      content += "#{index + 1}##{key.capitalize}##{value}\n"
    end
    content
  end
end