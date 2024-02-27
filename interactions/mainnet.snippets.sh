PROJECT="${PWD}"

COLLECTION_ID="XCASTLE-ee733b"
COLLECTION_ID_HEX="0x$(echo -n ${COLLECTION_ID} | xxd -p -u | tr -d '\n')"

ECCU_ID="ECCU-29891f"
ECCU_ID_HEX="0x$(echo -n ${ECCU_ID} | xxd -p -u | tr -d '\n')"

FOOD_ID="FOOD-46261d"
FOOD_ID_HEX="0x$(echo -n ${FOOD_ID} | xxd -p -u | tr -d '\n')"

BEER_ID="BEER-093bf2"
BEER_ID_HEX="0x$(echo -n ${BEER_ID} | xxd -p -u | tr -d '\n')"

WOOD_ID="WOOD-2f70ee"
WOOD_ID_HEX="0x$(echo -n ${WOOD_ID} | xxd -p -u | tr -d '\n')"

STONE_ID="STONE-6830a4"
STONE_ID_HEX="0x$(echo -n ${STONE_ID} | xxd -p -u | tr -d '\n')"

IRON_ID="IRON-abe3cd"
IRON_ID_HEX="0x$(echo -n ${IRON_ID} | xxd -p -u | tr -d '\n')"

WARGEAR_ID="WARGEAR-932f1d"
WARGEAR_ID_HEX="0x$(echo -n ${WARGEAR_ID} | xxd -p -u | tr -d '\n')"

PEM_FILE="/home/edimarian/Desktop/wallet-estar/wallet-owner.pem"
PROXY=https://gateway.multiversx.com
CHAINID=1
ADDRESS=erd1qqqqqqqqqqqqqpgqdjfrnwzygxl06n2v0js6ar0vjwgmcjnswmfsays9c6
MY_ADDRESS="erd1szcgm7vq3tmyxfgd4wd2k2emh59az8jq5jjpj9799a0k59u0wmfss4vw3v"


deploy() {
  mxpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${PEM_FILE} \
    --gas-limit=60000000 --send --outfile="${PROJECT}/interactions/logs/deploy.json" \
    --proxy=${PROXY} --chain=${CHAINID} \
    --arguments $COLLECTION_ID_HEX $ECCU_ID_HEX $FOOD_ID_HEX $BEER_ID_HEX $WOOD_ID_HEX $STONE_ID_HEX $IRON_ID_HEX $WARGEAR_ID_HEX || return
}

updateContract() {
  mxpy --verbose contract upgrade ${ADDRESS} --bytecode="${PROJECT}/output/stake.wasm" --recall-nonce --pem=${PEM_FILE} \
    --gas-limit=100000000 --send --outfile="${PROJECT}/interactions/logs/update.json" \
    --proxy=${PROXY} --chain=${CHAINID} \
    --arguments $COLLECTION_ID_HEX $ECCU_ID_HEX $FOOD_ID_HEX $BEER_ID_HEX $WOOD_ID_HEX $STONE_ID_HEX $IRON_ID_HEX $WARGEAR_ID_HEX
}

togglePause() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="togglePause" \
    --send \
    --outfile="${PROJECT}/interactions/logs/toggle-pause.json"
}

setSftsAllowed() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=60000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftsAllowed" \
    --arguments 2 9 35 19 41 23 49 29 55 37 43 51 57 6 34 17 40 24 47 30 54 3 36 16 42 22 50 27 56 4 33 18 39 25 46 31 53 38 44 52 58 5 7 14 15 20 21 26 28 \
    --send \
    --outfile="${PROJECT}/interactions/logs/set-sfts-allowed.json"
}

removeSftsAllowed() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="removeSftsAllowed" \
    --arguments 2 3 4 5 6 7 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 \
    --send \
    --outfile="${PROJECT}/interactions/logs/remove-sfts-allowed.json"
}

setSftEccu() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftEccu" \
    --arguments 9 1 \
    --send \
    --outfile="${PROJECT}/interactions/logs/set-sfts-reward.json"
}

setSftResource() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftResource" \
    --arguments 5 0 \
    --send \
    --outfile="${PROJECT}/interactions/logs/set-sfts-reward.json"
}

eccuFund() {
  method_name="0x$(echo -n 'eccuFund' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTTransfer" \
    --arguments $ECCU_ID_HEX 200000 $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/fund-system.json"
}

foodFund() {
  method_name="0x$(echo -n 'foodFund' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTTransfer" \
    --arguments $FOOD_ID_HEX 200000000000000000000000 $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/fund-system.json"
}

wargearFund() {
  method_name="0x$(echo -n 'wargearFund' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTTransfer" \
    --arguments $WARGEAR_ID_HEX 200000000000000000000000 $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/fund-system.json"
}

test() {
  method_name="0x$(echo -n 'setTokenAmount' | xxd -p -u | tr -d '\n')"
  token="0x$(echo -n 'XCASTLE-ee733b' | xxd -p -u | tr -d '\n')"
  token_swapped="0x$(echo -n 'COMMONCHAR-435910' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${MY_ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTNFTTransfer" \
    --arguments $token 12 100 erd1qqqqqqqqqqqqqpgqzfu6mh4ryxmv2x7va4cuc437nh3qaq7lwmfs2fctds $method_name $token_swapped 6  \
    --send \
    --outfile="${PROJECT}/interactions/logs/fund-system.json"
}

withdrawFunds() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="withdrawFunds" \
    --arguments 1 \
    --send \
    --outfile="${PROJECT}/interactions/logs/withdraw-funds.json"
}

stake() {
  method_name="0x$(echo -n 'stake' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${MY_ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=60000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTNFTTransfer" \
    --arguments $COLLECTION_ID_HEX 3 1 $ADDRESS $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/stake.json"
}

unStake() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="unStake" \
    --arguments $COLLECTION_ID_HEX 2 1 \
    --send \
    --outfile="${PROJECT}/interactions/logs/unstake.json"
}

withdrawFunds() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="withdrawFunds" \
    --arguments 54023 \
    --send \
    --outfile="${PROJECT}/interactions/logs/unstake.json"
}

getCollection() {
  mxpy --verbose contract query ${ADDRESS} --function="getCollection" \
    --proxy=${PROXY}
}

getPause() {
  mxpy --verbose contract query ${ADDRESS} --function="getPause" \
    --proxy=${PROXY}
}

getSftsAllowed() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftsAllowed" \
    --proxy=${PROXY}
}

getSftsStaked() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftsStaked" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}

getSftStakedAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftStakedAmount" --arguments $MY_ADDRESS 1 \
    --proxy=${PROXY}
}

getSftStakedAt() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftStakedAt" --arguments $MY_ADDRESS 1 \
    --proxy=${PROXY}
}

getSftReward() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftReward" --arguments 1 \
    --proxy=${PROXY}
}

getUsersStaked() {
  mxpy --verbose contract query ${ADDRESS} --function="getUsersStaked" \
    --proxy=${PROXY}
}

getTokenPayment() {
  mxpy --verbose contract query ${ADDRESS} --function="getTokenPayment" \
    --proxy=${PROXY}
}

getEccuAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getEccuAmount" \
    --proxy=${PROXY}
}

getRewards() {
  mxpy --verbose contract query ${ADDRESS} --function="getRewards" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}