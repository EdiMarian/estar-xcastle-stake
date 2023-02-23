PROJECT="${PWD}"

TOKEN_ID="XCARD-6c24da"
TOKEN_ID_HEX="0x$(echo -n ${TOKEN_ID} | xxd -p -u | tr -d '\n')"

TOKEN_TEST_ID="ANOTHERCOL-60e481"
TOKEN_TEST_ID_HEX="0x$(echo -n ${TOKEN_TEST_ID} | xxd -p -u | tr -d '\n')"

PEM_FILE="/home/edi/Desktop/my-wallet/my_wallet.pem"
PROXY=https://devnet-gateway.multiversx.com
CHAINID=D
ADDRESS=erd1qqqqqqqqqqqqqpgqwureq34kdmk26c7mfp8errmrkevlugdlxszqnxre89
MY_ADDRESS="erd1a6p39rlsn2lm20adqe5tmzy543luwqx4dywzflr2dmtwdf75xszqdw9454"


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
    --arguments $TOKEN_ID_HEX 1 2 $ADDRESS $method_name \
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

getUsersStaked() {
  mxpy --verbose contract query ${ADDRESS} --function="getUsersStaked" \
    --proxy=${PROXY}
}

getSftsStaked() {
  mxpy --verbose contract query ${ADDRESS} --function="getSftsStaked" --arguments $MY_ADDRESS \
    --proxy=${PROXY}
}