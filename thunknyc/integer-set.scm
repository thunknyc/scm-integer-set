(define (min-element els)
     (reduce min #f els))

(define (max-element els)
  (reduce max #f els))

(define (element-range els)
  (+ (- (max-element els) (min-element els)) 1))

(define (sparse? els)
  (and (> (length els) 0)
       (< (/ (length els) (element-range els)) 0.3)))

(define-record-type <integer-set>
  (construct-integer-set bitvector base subsets)
  integer-set?
  (bitvector integer-set-bitvector set-integer-set-bitvector!)
  (base integer-set-base set-integer-set-base!)
  (subsets integer-set-subsets set-integer-set-subsets!))

(define make-bv make-vector)
(define bv-length vector-length)
(define bv-ref vector-ref)
(define bv-set! vector-set!)
(define bv-fold vector-fold)

(define (flat-integer-set . elements)
  (let* ((base (min-element elements))
	 (n (element-range elements))
	 (bitvector (make-bv n 0)))
    (for-each (lambda (el)
		(bv-set! bitvector (- el base) 1))
	      elements)
    (construct-integer-set bitvector base '())))

(define (gap-too-big? el prev range n)
  (let ((gap (- el prev))
	(reciprocal-density (/ range n)))
    (and (> gap 256)
	 (> gap (* reciprocal-density 2)))))

(define (partition-fold els n range)
  (fold (lambda (el accum)
	  (let ((current (car accum)) (subsets (cdr accum)))
	    (cond ((null? current)
		   (cons (cons el '()) subsets))
		  ((gap-too-big? el (car current) range n)
		   (cons (cons el '())
			 (cons (apply flat-integer-set current)
			       subsets)))
		  (else (cons (cons el current) subsets)))))
	'(() . ()) (list-sort < els)))

(define (partition els)
  (let* ((accum (partition-fold els (length els) (element-range els)))
	 (current (car accum))
	 (subsets (cdr accum)))
    (if (null? current)
	subsets
	(cons (apply flat-integer-set current) subsets))))

(define (integer-set . elements)
  (if (sparse? elements)
      (let ((subsets (partition elements)))
	(cond ((null? subsets) (flat-integer-set))
	      (else (let ((set (car subsets))
			  (subsets (cdr subsets)))
		      (set-integer-set-subsets! set subsets)
		      set))))
      (apply flat-integer-set elements)))

(define (integer-set-contains? set element)
  (let* ((bitvector (integer-set-bitvector set))
	 (n (bv-length bitvector))
	 (base (integer-set-base set))
	 (ceiling (+ n base)))
    (or (and (>= element base)
	     (< element ceiling)
	     (= (bv-ref bitvector (- element base)) 1))
	(any (lambda (subset) (integer-set-contains? subset element))
	     (integer-set-subsets set)))))

(define (integer-set-for-each proc set)
  (let* ((bitvector (integer-set-bitvector set))
	 (n (bv-length bitvector))
	 (base (integer-set-base set)))
    (let loop ((i 0))
      (cond ((< i n)
	     (when (= (bv-ref bitvector i) 1) (proc (+ i base)))
	     (loop (+ i 1)))))
    (for-each (lambda (subset) (integer-set-for-each proc subset))
	      (integer-set-subsets set))))

(define (integer-set-fold proc nil set)
  (let* ((bitvector (integer-set-bitvector set))
	 (n (bv-length bitvector))
	 (base (integer-set-base set))
	 (accum (let loop ((i 0) (accum nil))
		  (cond ((= i n) accum)
			((= (bv-ref bitvector i) 1)
			 (loop (+ i 1) (proc (+ i base) accum)))
			(else (loop (+ i 1) accum))))))
    (fold (lambda (subset accum)
	    (integer-set-fold proc accum subset))
	  accum
	  (integer-set-subsets set))))

(define (integer-set-disjoint? s1 s2)
  (call-with-current-continuation
   (lambda (k)
     (integer-set-for-each
      (lambda (el) (if (integer-set-contains? s1 el) (k #f)))
      s2)
     #t)))

;; Derived procedures

(define (integer-set->list set)
  (integer-set-fold cons '() set))

(define (integer-set-member set element default)
  (if (integer-set-contains? set element) element default))

(define (integer-set-adjoin set element)
  (apply integer-set (cons element (integer-set->list set))))

(define integer-set-adjoin! integer-set-adjoin)
