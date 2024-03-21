class CoinApiService
  include HTTParty
  base_uri 'https://rest.coinapi.io/v1'

  def initialize(api_key)
    @options = { headers: { 'X-CoinAPI-Key' => api_key } }
  end

  def get_current_price(asset_id)
    response = self.class.get("/exchangerate/#{asset_id}/USD", @options)
    if response.success?
      JSON.parse(response.body)
    else
      retry_after_some_time
    end
  end

  def get_current_price_with_retry(asset_id, max_retries = 3)
    retries = 0
    begin
      response = self.class.get("/exchangerate/#{asset_id}/USD", @options)
      JSON.parse(response.body) if response.success?
    rescue StandardError => e
      retries += 1
      retry if retries < max_retries
      handle_error(e)
    end
  end

  private

  def retry_after_some_time
    sleep(5) 
  end

  def handle_error(error)
  end
end