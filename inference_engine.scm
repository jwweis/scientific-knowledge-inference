;;;; inference_engine.scm

(load "load")
(load "pattern_matcher")

(define all-knowledge)
(define all-rules)

(define (ie:init)
  (set! all-knowledge '())
  (set! all-rules '())
  (set! compound_obj_aliases '()))

(define (ie:has-statement knowledge new_knowledge)
  (define (statement-of k)
    (cons (car k) (cadr k)))

  (if (null? knowledge)
      #f
      (or (equal? (statement-of new_knowledge) (statement-of (car knowledge)))
          (ie:has-statement (cdr knowledge) new_knowledge))))

(define (ie:add-knowledge2 knowledge)
  (set! all-knowledge (append all-knowledge knowledge)))

(define (ie:add-knowledge new-knowledge)
  (if (not (ie:has-statement all-knowledge new-knowledge))
      (append-to-end! all-knowledge new-knowledge)))

;(define (ie:add-knowledge new-knowledge)
  ;(let ((filtered-new-knowledge
  ;       (filter (lambda (x) (not (member x all-knowledge))) new-knowledge)))
  ;  (set! all-knowledge (append all-knowledge filtered-new-knowledge))
  ;  ))

(define (ie:add-aliases new-aliases)
  (append! new-aliases compound_obj_aliases))

(define (ie:add-rules new-rules)
  (set! all-rules (append all-rules new-rules)))

(define (ie:print-knowledge)
  (pp all-knowledge))

(define (ie:is-true2 statement context_predicate)
  (ie:infer context_predicate)
  (ie:print-knowledge))
  ;(pp (ie:member statement all-knowledge)))

(define (ie:is-true statement context_predicate)
  (ie:infer context_predicate)
  
  (let ((matches_to_statement (ie:member statement all-knowledge)))
    (if (null? matches_to_statement)
      (pp "FALSE.")
      (if (= 1 (length matches_to_statement))
        (pp (cons "TRUE! Your statement matches:" matches_to_statement))
        (pp (cons "TRUE. Your statement matches multiple pieces of information in our database." matches_to_statement))
        )
      )
    ))

(define (ie:member statement current-knowledge)
  (ie:member-helper statement current-knowledge '()))

(define (ie:eq-arg? sArg kArg)
  (if (not (list? compound_obj_aliases))
      ; true
      (equal? sArg kArg)
      
      ; false
      (cond ((string? kArg) (equal? kArg sArg))
            ((symbol? kArg)
              (let ((alias_list (assoc sArg compound_obj_aliases)))
                (or (equal? kArg sArg)
                     (and alias_list (memq? kArg (cdr alias_list)) ))))
            (else (equal? kArg sArg))
      )
    ))

(define (ie:eq-args? args1 args2)
  (cond ((and (null? args1) (null? args2)) #t)
        ((not (ie:eq-arg? (car args1) (car args2))) #f)
        (else (ie:eq-args? (cdr args1) (cdr args2)))))

(define (ie:eq-statement-knowledge? sType sArgs kType kArgs)
  (and (equal? sType kType) (equal? (length sArgs) (length kArgs)) (ie:eq-args? sArgs kArgs)))

(define (ie:member-helper statement current-knowledge matches)
  (if (null? current-knowledge) matches 
    (let*  (
      (statementType (car statement)) 
      (statementArgs (car (cdr statement))) 
      (knowledgeType (car (car current-knowledge))) 
      (knowledgeArgs (car (cdr (car current-knowledge))))
      (sk-equal (ie:eq-statement-knowledge? statementType statementArgs knowledgeType knowledgeArgs)))
      
      (if sk-equal
        (set! matches (cons (car current-knowledge) matches)))
      
      (ie:member-helper statement (cdr current-knowledge) matches))))

(define (ie:infer context_predicate)

  (define (on_match knowledge matched_statements new_statement)
    ;(pp (list "!!!!! on_match" matched_statements "=>" new_statement))
    
    ; TODO: create knowledge from new statement and append! to knowledge
    
    (let* (
      (new_type (car new_statement))
      (new_args (cdr new_statement))
      (new_knowledge    
        (list new_type new_args (list
        (cons "inferred_from" matched_statements)
        ))
      ))
    ;(append-to-end! knowledge new_knowledge)
    (ie:add-knowledge new_knowledge)
    ))
    
  (pm:match all-knowledge all-rules on_match compound_obj_aliases))

;; Tests
;(load "./simple_data/knowledge.scm")
;(pp knowledge)

;Value: ()

;(ie:print-knowledge)
; ()

#|
(define excess-knowledge (list
(list 'CAUSE (list "shooting guards" 'score)
      (list
       (cons "title" "title1")
       (cons "author" "author1")
       (cons "year" "year1")
       (cons "university" "univ1")
       (cons "topic" "topic1")
       (cons "journal" "journal1")
       (cons "pubmed" "pubmed1")
       (cons "locations" (list "loc_a1" "loc_b1"))))))
|#
;Value: excess-knowledge


;(ie:add-knowledge excess-knowledge)
;Value: ()

;(ie:print-knowledge)
;; ((cause
;;   ("shooting guards" score)
;;   (("title" . "title1")
;;    ("author" . "author1")
;;    ("year" . "year1")
;;    ("university" . "univ1")
;;    ("topic" . "topic1")
;;    ("journal" . "journal1")
;;    ("pubmed" . "pubmed1")
;;    ("locations" "loc_a1" "loc_b1"))))

;(ie:add-knowledge excess-knowledge)
;; ;Value: ((cause ("shooting guards" score)
;; (("title" . "title1") ("author" . "author1") ("year" . "year1")
;;  ("university" . "univ1") ("topic" . "topic1") ("journal" . "journal1")
;;  ("pubmed" . "pubmed1") ("locations" "loc_a1" "loc_b1"))))

;(ie:print-knowledge)
;; ((cause
;;   ("shooting guards" score)
;;   (("title" . "title1")
;;    ("author" . "author1")
;;    ("year" . "year1")
;;    ("university" . "univ1")
;;    ("topic" . "topic1")
;;    ("journal" . "journal1")
;;    ("pubmed" . "pubmed1")
;;    ("locations" "loc_a1" "loc_b1"))))

;(ie:is-true (list 'CAUSE (list 'lakers 'kobe)) '())
;(ie:is-true (list 'CAUSE (list 'rain 'water)) '())
;(ie:is-true (list 'CAUSE (list "shooting guards" 'win)) '())



; Expect to return true.

