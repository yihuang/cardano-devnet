> The script is adapted from [mkfiles.sh](https://github.com/input-output-hk/cardano-node/blob/master/scripts/byron-to-mary/mkfiles.sh)

## TODO
- Support sophisticated configuration for devnet
  - setup how many nodes
  - initial fund distribution
  - what protocol and era to run

## Prerequisite

- [supervisor](https://pypi.org/project/supervisor/)
- cardano-node/cardano-cli

## Initial start

```shell
$ ./serve.sh
```

It will setup and run a byron-shelley hardfork chain, and upgrade from byron era all the way to mary era automatically, you just need to wait for 2.5 minutes.

Run following command to check if mary era is ready:

```shell
$ export CARDANO_NODE_SOCKET_PATH=./example/node-bft1/node.sock
$ cardano-cli query protocol-parameters --testnet-magic 42 --mary-era
```

After initialized, you can also start the chain by using supervisor:

```shell
$ supervisord -n -c supervisor.conf
```

## Mint native tokens

```
$ ./mint.sh
$ cardano-cli query utxo --mary-era --testnet-magic 42
                           TxHash                                 TxIx        Amount
--------------------------------------------------------------------------------------
3b41a5a285a6d49bde9af135e6401a2d56e42038545ca1499bbb2d2003a44283     0        500000000 lovelace + 5 3a81eb62beb1d114049fe8b80b7b640368de7302d6d79dfb8a191cf1.ADAHODL
c4eace400e11b4996d97ebacbcfb094cc1f886ef665b7bd18073933881e940d8     0        500000000 lovelace
```



