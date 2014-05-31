#!/bin/bash

set -e

mounts="/:/mnt/nfs"
targets=()

for mnt in "${mounts[@]}"; do
  src=$(echo $mnt | awk -F':' '{ print $1 }')
  target=$(echo $mnt | awk -F':' '{ print $2 }')
  targets+=("$target")

  mkdir -p $target

  mount -t nfs4 -o proto=tcp,port=2049 ${NFS_PORT_2049_TCP_ADDR}:${src} ${target}
done

exec inotifywait -m "${targets[@]}" >> /var/log/nfs-client.log 2>&1
