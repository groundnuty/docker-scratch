#!/bin/bash

layer_file=$1
TMP_DIR=$(mktemp -d)

echo "Exracting layer to $TMP_DIR"
tar xvf $layer_file  -C $TMP_DIR
config=$(find $TMP_DIR -maxdepth 1 \( -iname "*.json" ! -iname "manifest.json" \))
image_name=$(cat $TMP_DIR/image_name)

rm $TMP_DIR/image_name

layer=$(find $TMP_DIR -mindepth 2 -iname "layer.tar" )

echo $config
base_image=$(cat $config | tr ',' "\n" | grep Image | tail -n1 | cut -d '"' -f 4)
echo "Pulling base image $base_image"
docker pull $base_image

#sed -i "s#\"Image\":\"\"#\"Image\":\"$image_name\"#g" $config
#sed -i "s#\"Image\":\"$base_image\"#\"Image\":\"$image_name\"#g" $config

echo "Addind layer to $base_image"
docker save "$base_image" | tar xvf - -C $TMP_DIR

config=$(basename $config)
find $TMP_DIR -maxdepth 1 \( -iname "*.json" ! -iname "manifest.json" ! -iname $config \) -exec rm {} \;
sed -i "s/\"Config\":\".*\.json\",/\"Config\":\"$config\",/g" $TMP_DIR/manifest.json

echo "Setting new image name to $image_name"
sed -i "s#\"RepoTags\":\[\"$base_image\"\]#\"RepoTags\":[\"$image_name\"]#g" $TMP_DIR/manifest.json

layer=${layer#$TMP_DIR/}
echo $layer
sed -i "s#]}]#,\"$layer\"]}]#g" $TMP_DIR/manifest.json

tar -cf - -C $TMP_DIR . | docker load

echo "Removing temporary directory ($TMP_DIR)"
rm -rf $TMP_DIR

