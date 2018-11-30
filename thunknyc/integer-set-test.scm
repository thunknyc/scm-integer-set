(import (scheme red) (thunknyc integer-set) (chibi test))

(test-begin "(thunknyc integer-set")

(let ((s1 (integer-set 1 2 3 5))
      (s2 (integer-set 4 6))
      (s3 (integer-set 1 2 3 1000 54 23 60 200 500)))
  (test "Non-membership" #f (integer-set-contains? s1 42))
  (test "Membership" #t (integer-set-contains? s1 3))
  (test "Disjointness" #t (integer-set-disjoint? s1 s2))
  (test "Sparse disjointness" #t (integer-set-disjoint? s2 s3)))

(test-end)
(test-exit)
