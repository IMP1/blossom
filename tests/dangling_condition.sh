# dangling_condition

echo "rule foo    [ 1, 2 | 1->2 ]"  >> tmp.blsm
echo "         => [ 1 ]"            >> tmp.blsm
echo "end"                          >> tmp.blsm
echo "foo"                          >> tmp.blsm

./ruby_interpreter/blossom tmp.blsm "[1, 2, 3 | 1->2, 2->3 ]"

# Graph
#
#   1 -----> 2 -----> 3
#
#
# Rule
#   1 ----> 2    =>    1
#

rm tmp.blsm