# rule_matching

echo "rule foo    <int x, y>"                      >> tmp.blsm
echo "            [ 1 (x), 2 (y) | 1->2 (empty) ]" >> tmp.blsm
echo "         => [ 1 (x), 2 (y) | 1->2 (0) ]"     >> tmp.blsm
echo "end"                                         >> tmp.blsm
echo "foo"                                         >> tmp.blsm

./ruby_interpreter/blossom tmp.blsm "[1 (2), 2 (1), 3(3) | 1->2, 2->3, 1->3 ]"

# Graph
#          (0)        (0)
#   2(1) <----- 1(2) -----> 3(3)
#      \                    ^
#      \-------------------|
#               (0)
#
# Rule
#         (0)                      (1)
#   1(x) ----> 2(y)    =>    1(x) ----> 2(y)
#
#

rm tmp.blsm