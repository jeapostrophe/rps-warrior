#lang racket/base
(require racket/match
         "random.rkt")

(struct fst (states input-alpha output-alpha start delta state->output) #:transparent)

(define (random-state how-many-states)
  (random (add1 how-many-states)))

(define (random-one-state-fst input output)
  (define state_0 0)
  (fst state_0 input output state_0
       (hash state_0
             (for/hash ([i (in-list input)])
               (values i state_0)))
       (hash state_0
             (random-list-ref output))))

(define (mutate-fst f)
  (match-define (fst states input-alpha output-alpha start delta state->output) f)
  (define (change-output state->output random-state)
    (hash-set state->output random-state
              (random-list-ref output-alpha)))
  (define (change-transition delta from-state to-state)
    (hash-update delta from-state
                 (λ (input->next)
                   (hash-set input->next (random-list-ref input-alpha) to-state))))
  (random-case
   [1/2
    ; Add a new state
    (define new-state (add1 states))
    (fst new-state input-alpha output-alpha start
         ; Linked to by a random existing state
         (change-transition
          ; with random transitions to other stats
          (hash-set delta new-state
                    (for/hash ([i (in-list input-alpha)])
                      (values i (random-state new-state))))
          (random-state states)
          new-state)
         ; and a random output
         (change-output state->output new-state))]
   ; Add a transition
   [1/6
    (fst states input-alpha output-alpha start
         (change-transition delta (random-state states)
                            (random-state states))
         state->output)]
   ; Change an output
   [1/6
    (fst states input-alpha output-alpha start
         delta
         (change-output state->output (random-state states)))]
   ; Change the start state
   [1/6
    (fst states input-alpha output-alpha
         (random-state states)
         delta state->output)]))

(define (fst-output f s)
  (hash-ref (fst-state->output f) s))

(define (fst-next f s i)
  (hash-ref (hash-ref (fst-delta f) s) i))

(provide (all-defined-out))  