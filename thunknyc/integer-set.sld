(define-library (thunknyc integer-set)
  (import (scheme red))
  (export integer-set integer-set? integer-set-contains? integer-set-disjoint?
		       ;; integer-set-member integer-set-adjoin integer-set-adjoin! integer-set-replace integer-set-replace! integer-set-delete integer-set-delete! integer-set-delete-all integer-set-delete-all! integer-set-search! ... AND A TON MORE
		       )
  (include "integer-set.scm"))
