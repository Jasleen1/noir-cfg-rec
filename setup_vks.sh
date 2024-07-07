BACKEND=~/.bb/bb

BASE_CIRC=./base_parsing_circuit
BASE_REC_CIRC=./base_rec_parsing_circuit
REC_CIRC=./rec_parsing_circuit

mkdir -p vks
#### Compile the first package and write its vks
nargo compile --silence-warnings --package base_parsing_circuit
$BACKEND write_vk -b ./target/base_parsing_circuit.json  -o ./target/vk_base
$BACKEND vk_as_fields -k ./target/vk_base -o ./target/vk_base_as_fields

VK_HASH=$(jq -r '.[0]' ./target/vk_base_as_fields)
VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_base_as_fields)

VK_FILE=./vks/base_vk
echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
echo "key_hash=\"$VK_HASH\"" >> $VK_FILE

#### Compile the second package and write its vks
nargo compile --silence-warnings --package base_rec_parsing_circuit
$BACKEND write_vk -b ./target/base_rec_parsing_circuit.json  -o ./target/vk_base_rec
$BACKEND vk_as_fields -k ./target/vk_base_rec -o ./target/vk_base_rec_as_fields

VK_HASH=$(jq -r '.[0]' ./target/vk_base_rec_as_fields)
VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_base_rec_as_fields)

VK_FILE=./vks/base_rec_vk
echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
echo "key_hash=\"$VK_HASH\"" >> $VK_FILE


#### Compile the third package and write its vks
nargo compile --silence-warnings --package rec_parsing_circuit
$BACKEND write_vk -b ./target/rec_parsing_circuit.json  -o ./target/vk_rec
$BACKEND vk_as_fields -k ./target/vk_rec -o ./target/vk_rec_as_fields

VK_HASH=$(jq -r '.[0]' ./target/vk_rec_as_fields)
VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_rec_as_fields)

VK_FILE=./vks/rec_vk
echo "verification_key=$VK_AS_FIELDS"  > $VK_FILE
echo "key_hash=\"$VK_HASH\"" >> $VK_FILE