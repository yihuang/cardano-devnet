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
ADDR=$(cardano-cli address build --payment-verification-key-file example/shelley/utxo-keys/utxo1.vkey --testnet-magic 42)
TXID=$(cardano-cli genesis initial-txin --testnet-magic 42 --verification-key-file ./example/shelley/utxo-keys/utxo1.vkey)
cardano-cli transaction build-raw --mary-era --fee 0 \
  --tx-in $TXID \
  --tx-out "$ADDR+5 $POLICYID.ADAHODLERS+1000000000" \
  --mint "5 $POLICYID.ADAHODLERS" \
  --out-file mint.tx
cardano-cli transaction sign \
  --signing-key-file example/shelley/utxo-keys/utxo1.skey \
  --signing-key-file policy.skey \
  --script-file policy.script \
  --testnet-magic 42 \
  --tx-body-file mint.tx \
  --out-file mint.tx.signed
cardano-cli transaction submit --tx-file mint.tx.signed --testnet-magic 42
