#!/bin/bash

PWD=$PWD
CONTAINER=$1

TMP_DIR=$(mktemp -d)
base_image=$(docker inspect --format="{{.Config.Image}}" $CONTAINER)

image_name="$base_image""-crashlog-"$(date "+%Y-%m-%d_%H-%M-%S_%Z" |  tr '[:upper:]' '[:lower:]' )
#image_name="onedata/oneprovider:VFS-2062-crashlog-Sat_May_28_12_42_50_UTC_2016"
echo $image_name > $TMP_DIR/image_name

echo "Commiting container $CONTAINER as image $image_name"
docker commit $CONTAINER "$image_name"
tar_name="$TMP_DIR/"$(echo $image_name | tr "/:" "_").tar

echo "Exporting image $image_name to $TMP_DIR"
docker save "$image_name" | tar xvf - -C $TMP_DIR

echo "Extracting container layer from image"
manifest=$TMP_DIR"/manifest.json"
layer_dir=$(cat  $manifest | tr "," "\n" | tail -n1 | cut -d '"' -f 2 | cut -d '/' -f1)

echo "Saving container layer to $tar_name"
config_file=$(find $TMP_DIR -maxdepth 1 \( -iname "*.json" ! -iname "manifest.json" \))

tar cfv "$tar_name" -C $TMP_DIR ${config_file#$TMP_DIR/} $layer_dir image_name
mv "$tar_name" $PWD/

echo "Archive with container layer: ""$tar_name"

echo "Removing temporary directory ($TMP_DIR) and image ($image_name)"
rm -rf $TMP_DIR
docker rmi $image_name
