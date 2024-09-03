BACKEND="$1"

VK_DIR="$2"

BASE_CIRC=./dfs_stack_base
BASE_REC_CIRC=./dfs_stack_rec_1
REC_CIRC=./dfs_stack_full_rec

mkdir -p vks
mkdir -p target


mkdir -p "./vks/$VK_DIR"
STORAGE_DIR="./vks/$VK_DIR"
#### Compile the first package and write its vks
# nargo compile --silence-warnings --package dfs_stack_base
gtime -v nargo compile --silence-warnings --package dfs_stack_base #--expression-width=32 
cp ./target/dfs_stack_base.json $STORAGE_DIR
echo "Compiled package"

$BACKEND write_vk -b ./target/dfs_stack_base.json  -o ./target/vk_base
cp ./target/vk_base $STORAGE_DIR
echo "Written vk for base parsing circuit"

###### Below is only needed if you're doing a recursive circuit later


# $BACKEND vk_as_fields -k ./target/vk_base -o ./target/vk_base_as_fields
# echo "Written vk as fields for base parsing circuit"
# cp ./target/vk_base $STORAGE_DIR
# cp ./target/vk_base_as_fields $STORAGE_DIR



# VK_HASH=$(jq -r '.[0]' ./target/vk_base_as_fields)
# VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_base_as_fields)

# VK_FILE=./vks/$VK_DIR/base_vk
# echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
# echo "key_hash=\"$VK_HASH\"" >> $VK_FILE

# #### Compile the second package and write its vks
# nargo compile --silence-warnings --package dfs_stack_rec_1
# $BACKEND write_vk -b ./target/dfs_stack_rec_1.json  -o ./target/vk_base_rec
# $BACKEND vk_as_fields -k ./target/vk_base_rec -o ./target/vk_base_rec_as_fields
# echo "Written vk as fields for first recursive parsing circuit"
# cp ./target/vk_base_rec $STORAGE_DIR
# cp ./target/vk_base_rec_as_fields $STORAGE_DIR


# VK_HASH=$(jq -r '.[0]' ./target/vk_base_rec_as_fields)
# VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_base_rec_as_fields)

# VK_FILE=./vks/$VK_DIR/base_rec_vk
# echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
# echo "key_hash=\"$VK_HASH\"" >> $VK_FILE


# #### Compile the third package and write its vks
# nargo compile --silence-warnings --package dfs_stack_full_rec
# $BACKEND write_vk -b ./target/dfs_stack_full_rec.json  -o ./target/vk_rec
# $BACKEND vk_as_fields -k ./target/vk_rec -o ./target/vk_rec_as_fields
# cp ./target/vk_rec $STORAGE_DIR
# cp ./target/vk_rec_as_fields $STORAGE_DIR

# VK_HASH=$(jq -r '.[0]' ./target/vk_rec_as_fields)
# VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_rec_as_fields)

# VK_FILE=./vks/$VK_DIR/rec_vk
# echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
# echo "key_hash=\"$VK_HASH\"" >> $VK_FILE

# echo "Written all vks"