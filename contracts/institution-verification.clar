;; Institution Verification Contract
;; Validates and verifies financial entities

(define-map verified-institutions principal bool)
(define-map institution-details principal {name: (string-ascii 100), license-id: (string-ascii 50), jurisdiction: (string-ascii 50)})

(define-data-var admin principal tx-sender)

;; Only allow the admin to perform certain operations
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Register a new financial institution
(define-public (register-institution (institution-principal principal) (name (string-ascii 100)) (license-id (string-ascii 50)) (jurisdiction (string-ascii 50)))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only admin can register institutions
    (asserts! (not (default-to false (map-get? verified-institutions institution-principal))) (err u2)) ;; Cannot register twice

    (map-set verified-institutions institution-principal true)
    (map-set institution-details institution-principal {name: name, license-id: license-id, jurisdiction: jurisdiction})
    (ok true)))

;; Remove a financial institution
(define-public (remove-institution (institution-principal principal))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only admin can remove institutions
    (asserts! (default-to false (map-get? verified-institutions institution-principal)) (err u3)) ;; Institution must exist

    (map-delete verified-institutions institution-principal)
    (map-delete institution-details institution-principal)
    (ok true)))

;; Check if an institution is verified
(define-read-only (is-verified (institution-principal principal))
  (default-to false (map-get? verified-institutions institution-principal)))

;; Get institution details
(define-read-only (get-institution-details (institution-principal principal))
  (map-get? institution-details institution-principal))

;; Update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u1)) ;; Only current admin can set a new admin
    (var-set admin new-admin)
    (ok true)))
