PROJECT="${PWD}"

COLLECTION_ID="XCASTLE-76113d"
COLLECTION_ID_HEX="0x$(echo -n ${COLLECTION_ID} | xxd -p -u | tr -d '\n')"

ECCU_ID="ECCU-f99634"
ECCU_ID_HEX="0x$(echo -n ${ECCU_ID} | xxd -p -u | tr -d '\n')"

FOOD_ID="FOOD-41d22e"
FOOD_ID_HEX="0x$(echo -n ${FOOD_ID} | xxd -p -u | tr -d '\n')"

BEER_ID="BEER-41d22e"
BEER_ID_HEX="0x$(echo -n ${BEER_ID} | xxd -p -u | tr -d '\n')"

WOOD_ID="WOOD-41d22e"
WOOD_ID_HEX="0x$(echo -n ${WOOD_ID} | xxd -p -u | tr -d '\n')"

STONE_ID="STONE-41d22e"
STONE_ID_HEX="0x$(echo -n ${STONE_ID} | xxd -p -u | tr -d '\n')"

IRON_ID="IRON-41d22e"
IRON_ID_HEX="0x$(echo -n ${IRON_ID} | xxd -p -u | tr -d '\n')"

WARGEAR_ID="WARGEAR-dddc4c"
WARGEAR_ID_HEX="0x$(echo -n ${WARGEAR_ID} | xxd -p -u | tr -d '\n')"

PEM_FILE="/home/edi-marian/Desktop/wallet-estar/wallet-owner.pem"
PROXY=https://devnet-gateway.multiversx.com
CHAINID=D
ADDRESS=erd1qqqqqqqqqqqqqpgqszdxmexgleuy3cayct4fh236sd6uvkcnwmfs945xuh
MY_ADDRESS=erd1szcgm7vq3tmyxfgd4wd2k2emh59az8jq5jjpj9799a0k59u0wmfss4vw3v


deploy() {
  mxpy --verbose contract deploy --recall-nonce --pem=${PEM_FILE} \
    --bytecode="${PROJECT}/output/stake.wasm" \
    --gas-limit=600000000 --send --outfile="${PROJECT}/interactions/logs/deploy.json" \
    --proxy=${PROXY} --chain=${CHAINID} \
    --arguments $COLLECTION_ID_HEX $ECCU_ID_HEX $FOOD_ID_HEX $BEER_ID_HEX $WOOD_ID_HEX $STONE_ID_HEX $IRON_ID_HEX $WARGEAR_ID_HEX || return
}

updateContract() {
  mxpy --verbose contract upgrade ${ADDRESS} --bytecode="${PROJECT}/output/stake.wasm" --recall-nonce --pem=${PEM_FILE} \
    --gas-limit=600000000 --send --outfile="${PROJECT}/interactions/logs/update.json" \
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
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftsAllowed" \
    --arguments 1 2 3 \
    --send \
    --outfile="${PROJECT}/interactions/logs/set-sfts-allowed.json"
}

removeSftsAllowed() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="removeSftsAllowed" \
    --arguments 8 9 10 \
    --send \
    --outfile="${PROJECT}/interactions/logs/remove-sfts-allowed.json"
}

setSftEccu() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftEccu" \
    --arguments 3 1 \
    --send \
    --outfile="${PROJECT}/interactions/logs/set-sfts-reward.json"
}

setSftResource() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftResource" \
    --arguments 3 2 \
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
    --arguments $FOOD_ID_HEX 1000000000000000000000 $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/fund-system.json"
}

ironFund() {
  method_name="0x$(echo -n 'ironFund' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTTransfer" \
    --arguments $IRON_ID_HEX 1000000000000000000000 $method_name \
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
    --arguments $COLLECTION_ID_HEX 3 2 $ADDRESS $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/stake.json"
}

unStake() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="unStake" \
    --arguments $COLLECTION_ID_HEX 3 1 \
    --send \
    --outfile="${PROJECT}/interactions/logs/unstake.json"
}

claimRewards() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="claimRewards" \
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

getResource() {
  mxpy --verbose contract query ${ADDRESS} --function="getResource" --arguments 3 \
    --proxy=${PROXY}
}

getTokenPayment() {
  mxpy --verbose contract query ${ADDRESS} --function="getTokenPayment" \
    --proxy=${PROXY}
}

getTokenAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getTokenAmount" \
    --proxy=${PROXY}
}

calculateReward() {
  mxpy --verbose contract query ${ADDRESS} --function="calculateReward" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}

getFood() {
  mxpy --verbose contract query ${ADDRESS} --function="getUserFood" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}

getEccuAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getEccuAmount" \
    --proxy=${PROXY}
}

getFoodAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getFoodAmount" \
    --proxy=${PROXY}
}

getIronAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getIronAmount" \
    --proxy=${PROXY}
}

getSftResource() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftResource" --arguments 2 \
    --proxy=${PROXY}
}