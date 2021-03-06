#!/bin/bash
set -e
CARDANO_NODE_SOCKET_PATH=./example/node-bft1/node.sock
cardano-cli address key-gen --verification-key-file policy.vkey --signing-key-file policy.skey
KEYHASH=$(cardano-cli address key-hash --payment-verification-key-file policy.vkey)
SLOTNUM=$(cardano-cli query tip --testnet-magic 42|jq ".slotNo")
SLOTNUM_BEFORE=$(($SLOTNUM + 10))
cat > policy.script << EOF
{
  "type": "all",
  "scripts":
  [
    {
      "type": "before",
      "slot": $SLOTNUM_BEFORE
    },
    {
      "type": "sig",
      "keyHash": "$KEYHASH"
    }
  ]
}
EOF
POLICYID=$(cardano-cli transaction policyid --script-file ./policy.script)
ADDR=$(cardano-cli address build --payment-verification-key-file example/shelley/utxo-keys/utxo1.vkey --testnet-magic 42)
TXID=$(cardano-cli genesis initial-txin --testnet-magic 42 --verification-key-file ./example/shelley/utxo-keys/utxo1.vkey)
echo "Mint 1 nft"
cardano-cli transaction build-raw --mary-era --fee 0 \
  --tx-in $TXID \
  --tx-out "$ADDR+1 $POLICYID.NFT+1000000000" \
  --mint "1 $POLICYID.NFT" \
  --invalid-hereafter $SLOTNUM_BEFORE \
  --out-file mint.tx
cardano-cli transaction sign \
  --signing-key-file example/shelley/utxo-keys/utxo1.skey \
  --signing-key-file policy.skey \
  --script-file policy.script \
  --testnet-magic 42 \
  --tx-body-file mint.tx \
  --out-file mint.tx.signed
cardano-cli transaction submit --tx-file mint.tx.signed --testnet-magic 42
echo "Wait for 10 seconds and try to mint same nft again... (will fail)"
sleep 10
TXID=$(cardano-cli query utxo --mary-era --testnet-magic 42 --address $ADDR|tail -n 1|cut -d ' ' -f 1)
cardano-cli transaction build-raw --mary-era --fee 0 \
  --tx-in $TXID#0 \
  --tx-out "$ADDR+2 $POLICYID.NFT+1000000000" \
  --mint "1 $POLICYID.NFT" \
  --out-file mint2.tx
cardano-cli transaction sign \
  --signing-key-file example/shelley/utxo-keys/utxo1.skey \
  --signing-key-file policy.skey \
  --script-file policy.script \
  --testnet-magic 42 \
  --tx-body-file mint2.tx \
  --out-file mint2.tx.signed
cardano-cli transaction submit --tx-file mint2.tx.signed --testnet-magic 42
