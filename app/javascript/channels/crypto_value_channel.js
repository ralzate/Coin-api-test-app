import consumer from "./consumer";

const bitcoinPrice = document.getElementById("bitcoin-price");
const ethereumPrice = document.getElementById("ethereum-price");
const cardanoPrice = document.getElementById("cardano-price");
const btcPriceExport = document.getElementById("bitcoin_price_export");
const ethPriceExport = document.getElementById("ethereum_price_export");
const adaPriceExport = document.getElementById("cardano_price_export");

const fetchPricesFromAPI = async () => {
  try {
    const response = await fetch("https://data.messari.io/api/v1/assets?fields=id,slug,symbol,metrics/market_data/price_usd");
    if (!response.ok) {
      throw new Error('Failed to fetch data');
    }
    const data = await response.json();
    const btcPrice = data['data'][0]['metrics']['market_data']['price_usd'].toFixed(2);
    const ethPrice = data['data'][1]['metrics']['market_data']['price_usd'].toFixed(2);
    const adaPrice = data['data'][4]['metrics']['market_data']['price_usd'].toFixed(2);

    updateUI(btcPrice, ethPrice, adaPrice);
  } catch (error) {
    console.error("Error: Data was not found", error);
    showError();
  }
}

const updateUI = (btcPrice, ethPrice, adaPrice) => {
  bitcoinPrice.innerText = btcPrice;
  ethereumPrice.innerText = ethPrice;
  cardanoPrice.innerText = adaPrice;

  btcPriceExport.value = btcPrice;
  ethPriceExport.value = ethPrice;
  adaPriceExport.value = adaPrice;
}

const showError = () => {
  // Aquí puedes mostrar un mensaje de error en la interfaz de usuario
  // Por ejemplo, puedes agregar un elemento HTML para mostrar el mensaje de error
  // y modificar el CSS para que sea visible para el usuario.
}

const printJSON = async (connected) => {
  while (connected) {
    await fetchPricesFromAPI();
    await sleep(120000);
  }
}

consumer.subscriptions.create("CryptoValueChannel", {
  connected() {
    printJSON(true);
  },

  disconnected() {
    printJSON(false);
  },
});