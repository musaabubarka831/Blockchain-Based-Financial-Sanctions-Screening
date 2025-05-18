;; Sanctions List Contract
;; Records restricted parties and jurisdictions

(define-map sanctioned-entities principal {reason: (string-ascii 200), timestamp: uint})
(define-map sanctioned-jurisdictions (string-ascii 50) {reason: (string-ascii 200), timestamp: uint})

(define-data-var admin principal tx-sender)

;; Only allow the admin to perform certain operations
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Add an entity to the sanctions list
(define-public (add-sanctioned-entity (entity principal) (reason (string-ascii 200)))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only admin can add sanctions
    (asserts! (not (is-sanctioned-entity entity)) (err u2)) ;; Entity not already sanctioned

    (map-set sanctioned-entities entity {reason: reason, timestamp: block-height})
    (ok true)))

;; Remove an entity from the sanctions list
(define-public (remove-sanctioned-entity (entity principal))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only admin can remove sanctions
    (asserts! (is-sanctioned-entity entity) (err u3)) ;; Entity must be sanctioned

    (map-delete sanctioned-entities entity)
    (ok true)))

;; Check if an entity is sanctioned
(define-read-only (is-sanctioned-entity (entity principal))
  (is-some (map-get? sanctioned-entities entity)))

;; Get sanction details for an entity
(define-read-only (get-entity-sanction-details (entity principal))
  (map-get? sanctioned-entities entity))

;; Add a jurisdiction to the sanctions list
(define-public (add-sanctioned-jurisdiction (jurisdiction (string-ascii 50)) (reason (string-ascii 200)))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only admin can add sanctions
    (asserts! (not (is-sanctioned-jurisdiction jurisdiction)) (err u2)) ;; Jurisdiction not already sanctioned

    (map-set sanctioned-jurisdictions jurisdiction {reason: reason, timestamp: block-height})
    (ok true)))

;; Remove a jurisdiction from the sanctions list
(define-public (remove-sanctioned-jurisdiction (jurisdiction (string-ascii 50)))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only admin can remove sanctions
    (asserts! (is-sanctioned-jurisdiction jurisdiction) (err u3)) ;; Jurisdiction must be sanctioned

    (map-delete sanctioned-jurisdictions jurisdiction)
    (ok true)))

;; Check if a jurisdiction is sanctioned
(define-read-only (is-sanctioned-jurisdiction (jurisdiction (string-ascii 50)))
  (is-some (map-get? sanctioned-jurisdictions jurisdiction)))

;; Get sanction details for a jurisdiction
(define-read-only (get-jurisdiction-sanction-details (jurisdiction (string-ascii 50)))
  (map-get? sanctioned-jurisdictions jurisdiction))

;; Update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only current admin can set a new admin
    (var-set admin new-admin)
    (ok true)))
