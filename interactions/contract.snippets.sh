PROJECT="${PWD}"

COLLECTION_ID="XCASTLE-ee733b"
COLLECTION_ID_HEX="0x$(echo -n ${COLLECTION_ID} | xxd -p -u | tr -d '\n')"

TOKEN_ID="ECCU-29891f"
TOKEN_ID_HEX="0x$(echo -n ${TOKEN_ID} | xxd -p -u | tr -d '\n')"

PEM_FILE="/home/edi/Desktop/wallet-estar/wallet-owner.pem"
PROXY=https://gateway.multiversx.com
CHAINID=1
ADDRESS=erd1qqqqqqqqqqqqqpgqdjfrnwzygxl06n2v0js6ar0vjwgmcjnswmfsays9c6
MY_ADDRESS="erd1szcgm7vq3tmyxfgd4wd2k2emh59az8jq5jjpj9799a0k59u0wmfss4vw3v"


deploy() {
  mxpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${PEM_FILE} \
    --gas-limit=60000000 --send --outfile="${PROJECT}/interactions/logs/deploy.json" \
    --proxy=${PROXY} --chain=${CHAINID} \
    --arguments $COLLECTION_ID_HEX $TOKEN_ID_HEX || return
}

updateContract() {
  mxpy --verbose contract upgrade ${ADDRESS} --project=${PROJECT} --recall-nonce --pem=${PEM_FILE} \
    --gas-limit=60000000 --send --outfile="${PROJECT}/interactions/logs/update.json" \
    --proxy=${PROXY} --chain=${CHAINID} \
    --arguments $COLLECTION_ID_HEX $TOKEN_ID_HEX
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
    --arguments 2 3 4 5 6 7 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 \
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

setSftsReward() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftsReward" \
    --arguments 2 5 3 7 4 5 5 7 6 7 7 5 14 12 15 12 16 15 17 15 18 10 19 12 20 25 21 25 22 25 23 25 24 25 25 25 26 50 27 50 28 50 29 50 30 50 31 50\
    --send \
    --outfile="${PROJECT}/interactions/logs/set-sfts-reward.json"
}

fundSystem() {
  method_name="0x$(echo -n 'fundSystem' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTTransfer" \
    --arguments $TOKEN_ID_HEX 400 $method_name \
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

getTokenPayment() {
  mxpy --verbose contract query ${ADDRESS} --function="getTokenPayment" \
    --proxy=${PROXY}
}

getTokenAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getTokenAmount" \
    --proxy=${PROXY}
}

getRewards() {
  mxpy --verbose contract query ${ADDRESS} --function="getRewards" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}