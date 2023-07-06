PROJECT="${PWD}"

COLLECTION_ID="XCASTLE-76113d"
COLLECTION_ID_HEX="0x$(echo -n ${COLLECTION_ID} | xxd -p -u | tr -d '\n')"

TOKEN_ID="ECCU-f99634"
TOKEN_ID_HEX="0x$(echo -n ${TOKEN_ID} | xxd -p -u | tr -d '\n')"

PEM_FILE="/home/edi-marian/Desktop/wallet-estar/wallet-owner.pem"
PROXY=https://devnet-gateway.multiversx.com
CHAINID=D
ADDRESS=erd1qqqqqqqqqqqqqpgqzw659r8gvgagdeh6fjpf2nday28y0tcxwmfsjps0yt
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

setSftsReward() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="setSftsReward" \
    --arguments 1 2 2 2 3 1 \
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
    --arguments $TOKEN_ID_HEX 100000 $method_name \
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
    --arguments $COLLECTION_ID_HEX 1 1 $ADDRESS $method_name \
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