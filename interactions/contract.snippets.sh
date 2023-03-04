PROJECT="${PWD}"

TOKEN_ID="XAC-db0359"
TOKEN_ID_HEX="0x$(echo -n ${TOKEN_ID} | xxd -p -u | tr -d '\n')"

TOKEN_XAPE_ID="XAPES-1d15a5"
TOKEN_XAPE_ID_HEX="0x$(echo -n ${TOKEN_XAPE_ID} | xxd -p -u | tr -d '\n')"

PEM_FILE="/home/edi/Desktop/wallet-xapes/wallet.pem"
PROXY=https://gateway.multiversx.com
CHAINID=1
ADDRESS=erd1qqqqqqqqqqqqqpgqnazwq686e4r58750mwm5hef4lsdwr4rmd8as3qn9eu
MY_ADDRESS="erd1hkh4mjgqa3njlae9r7meua4per2ga8l7k6akfw2j5p4l73zgd8as0vh83e"


deploy() {
  mxpy --verbose contract deploy --project=${PROJECT} --recall-nonce --pem=${PEM_FILE} \
    --gas-limit=60000000 --send --outfile="${PROJECT}/interactions/logs/deploy.json" \
    --proxy=${PROXY} --chain=${CHAINID} \
    --arguments $TOKEN_ID_HEX || return
}

updateContract() {
  mxpy --verbose contract upgrade ${ADDRESS} --project=${PROJECT} --recall-nonce --pem=${PEM_FILE} \
    --gas-limit=60000000 --send --outfile="${PROJECT}/interactions/logs/deploy.json" \
    --proxy=${PROXY} --chain=${CHAINID} \
    --arguments $TOKEN_ID_HEX
}

stake() {
  method_name="0x$(echo -n 'stake' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${MY_ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=60000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTNFTTransfer" \
    --arguments $TOKEN_ID_HEX 1 1 $ADDRESS $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/stake.json"
}

unStake() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="unStake" \
    --arguments $TOKEN_ID_HEX 1 1 \
    --send \
    --outfile="${PROJECT}/interactions/logs/unstake.json"
}

unBond() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="unBond" \
    --arguments $TOKEN_ID_HEX 1 15 \
    --send \
    --outfile="${PROJECT}/interactions/logs/unstake.json"
}

fundSystem() {
  method_name="0x$(echo -n 'fundSystem' | xxd -p -u | tr -d '\n')"
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="ESDTTransfer" \
    --arguments $TOKEN_XAPE_ID_HEX 50000000000000000000000 $method_name \
    --send \
    --outfile="${PROJECT}/interactions/logs/unstake.json"
}

withdrawFunds() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="withdrawFunds" \
    --arguments 98142999999999999999124 \
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

togglePause() {
  mxpy --verbose contract call ${ADDRESS} --recall-nonce \
    --pem=${PEM_FILE} \
    --gas-limit=30000000 \
    --proxy=${PROXY} --chain=${CHAINID} \
    --function="togglePause" \
    --send \
    --outfile="${PROJECT}/interactions/logs/unstake.json"
}

getUsersStaked() {
  mxpy --verbose contract query ${ADDRESS} --function="getUsersStaked" \
    --proxy=${PROXY}
}

getSftsStaked() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftsStaked" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}

getPause() {
  mxpy --verbose contract query ${ADDRESS} --function="getPause" \
    --proxy=${PROXY}
}

getRewards() {
  mxpy --verbose contract query ${ADDRESS} --function="getRewards" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}

getTokenAmount() {
  mxpy --verbose contract query ${ADDRESS} --function="getTokenAmount" \
    --proxy=${PROXY}
}