BACKEND="$1"

BASE_CIRC=./dfs_stack_base
BASE_REC_CIRC=./dfs_stack_rec_1
REC_CIRC=./dfs_stack_full_rec

mkdir -p vks
mkdir -p target
#### Compile the first package and write its vks
nargo compile --silence-warnings --package dfs_stack_base
$BACKEND write_vk -b ./target/dfs_stack_base.json  -o ./target/vk_base
echo "Written vk for base parsing circuit"
$BACKEND vk_as_fields -k ./target/vk_base -o ./target/vk_base_as_fields
echo "Written vk as fields for base parsing circuit"

VK_HASH=$(jq -r '.[0]' ./target/vk_base_as_fields)
VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_base_as_fields)

VK_FILE=./vks/base_vk
echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
echo "key_hash=\"$VK_HASH\"" >> $VK_FILE

#### Compile the second package and write its vks
nargo compile --silence-warnings --package dfs_stack_rec_1
$BACKEND write_vk -b ./target/dfs_stack_rec_1.json  -o ./target/vk_base_rec
$BACKEND vk_as_fields -k ./target/vk_base_rec -o ./target/vk_base_rec_as_fields
echo "Written vk as fields for first recursive parsing circuit"

VK_HASH=$(jq -r '.[0]' ./target/vk_base_rec_as_fields)
VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_base_rec_as_fields)

VK_FILE=./vks/base_rec_vk
echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
echo "key_hash=\"$VK_HASH\"" >> $VK_FILE


#### Compile the third package and write its vks
nargo compile --silence-warnings --package dfs_stack_full_rec
$BACKEND write_vk -b ./target/dfs_stack_full_rec.json  -o ./target/vk_rec
$BACKEND vk_as_fields -k ./target/vk_rec -o ./target/vk_rec_as_fields

VK_HASH=$(jq -r '.[0]' ./target/vk_rec_as_fields)
VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_rec_as_fields)

VK_FILE=./vks/rec_vk
echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
echo "key_hash=\"$VK_HASH\"" >> $VK_FILE

echo "Written all vks"