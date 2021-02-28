#!/bin/bash
DATA=${1:-"./data"}
rm -rf $DATA
mkdir $DATA
cp ./genesis.spec.json $DATA
cp ./config.json $DATA
cardano-cli genesis create --testnet-magic 42 \
    --genesis-dir $DATA \
    --gen-genesis-keys 1 \
    --gen-utxo-keys 1
jq -r --arg systemStart $(date --utc +"%Y-%m-%dT%H:%M:%SZ" --date="5 seconds") \
    '.systemStart = $systemStart | .updateQuorum = 1' \
    $DATA/genesis.json | sponge $DATA/genesis.json
cat > $DATA/topology.yaml << EOF
{"Producers":[]}
EOF
cardano-node run \
    --config $DATA/config.json \
    --database-path $DATA/db \
    --topology $DATA/topology.yaml \
    --host-addr 127.0.0.1 \
    --port 30001 \
    --socket-path $DATA/node.socket \
    --shelley-vrf-key $DATA/delegate-keys/delegate1.vrf.skey \
    --shelley-kes-key $DATA/delegate-keys/delegate1.kes.skey \
    --shelley-operational-certificate $DATA/delegate-keys/opcert1.cert
echo $DATA/node.socket
