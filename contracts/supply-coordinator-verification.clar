;; Supply Coordinator Verification Contract
;; Validates and manages aerospace supply coordinators

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_FOUND (err u102))
(define-constant ERR_INVALID_STATUS (err u103))

;; Data structures
(define-map coordinators
  { coordinator: principal }
  {
    verified: bool,
    certification-level: uint,
    verification-date: uint,
    specialization: (string-ascii 50)
  }
)

(define-map coordinator-stats
  { coordinator: principal }
  {
    total-orders: uint,
    successful-deliveries: uint,
    rating: uint
  }
)

;; Public functions
(define-public (verify-coordinator (coordinator principal) (cert-level uint) (specialization (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? coordinators { coordinator: coordinator })) ERR_ALREADY_VERIFIED)
    (map-set coordinators
      { coordinator: coordinator }
      {
        verified: true,
        certification-level: cert-level,
        verification-date: block-height,
        specialization: specialization
      }
    )
    (map-set coordinator-stats
      { coordinator: coordinator }
      {
        total-orders: u0,
        successful-deliveries: u0,
        rating: u5
      }
    )
    (ok true)
  )
)

(define-public (update-coordinator-stats (coordinator principal) (orders uint) (deliveries uint) (rating uint))
  (begin
    (asserts! (is-some (map-get? coordinators { coordinator: coordinator })) ERR_NOT_FOUND)
    (map-set coordinator-stats
      { coordinator: coordinator }
      {
        total-orders: orders,
        successful-deliveries: deliveries,
        rating: rating
      }
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (is-verified-coordinator (coordinator principal))
  (match (map-get? coordinators { coordinator: coordinator })
    coordinator-data (get verified coordinator-data)
    false
  )
)

(define-read-only (get-coordinator-info (coordinator principal))
  (map-get? coordinators { coordinator: coordinator })
)

(define-read-only (get-coordinator-stats (coordinator principal))
  (map-get? coordinator-stats { coordinator: coordinator })
)
