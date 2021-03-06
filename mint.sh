#!/bin/bash
set -e
CARDANO_NODE_SOCKET_PATH=./example/node-bft1/node.sock
cardano-cli address key-gen --verification-key-file policy.vkey --signing-key-file policy.skey
KEYHASH=$(cardano-cli address key-hash --payment-verification-key-file policy.vkey)
cat > policy.script << EOF
{
  "keyHash": "$KEYHASH",
  "type": "sig"
}
EOF
POLICYID=$(cardano-cli transaction policyid --script-file ./policy.script)
ADDR=$(cat ./example/byron/address-000-converted)
TXID=$(cardano-cli query utxo --mary-era --testnet-magic 42 --address $ADDR|tail -n 1|cut -d ' ' -f 1)
cardano-cli transaction build-raw --mary-era --fee 0 \
  --tx-in $TXID#0 \
  --tx-out "$ADDR+5 $POLICYID.ADAHODLERS+500000000" \
  --mint "5 $POLICYID.ADAHODLERS" \
  --out-file mint.tx
cardano-cli transaction sign \
  --signing-key-file example/byron/payment-keys.000-converted.skey \
  --signing-key-file policy.skey \
  --script-file policy.script \
  --testnet-magic 42 \
  --tx-body-file mint.tx \
  --out-file mint.tx.signed
cardano-cli transaction submit --tx-file mint.tx.signed --testnet-magic 42
