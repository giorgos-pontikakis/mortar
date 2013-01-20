(in-package :mortar)


;;; ------------------------------------------------------------
;;; Utilities
;;; ------------------------------------------------------------

(defclass webapp/db (webapp)
  ((db-connection-spec :accessor db-connection-spec :initarg :db-connection-spec)))

(defmacro with-db (&optional db-connection-spec &body body)
  (with-gensyms (db)
    `(if *database*
         (progn
           ,@body)
         (let ((,db (or ,db-connection-spec (db-connection-spec (default-webapp)))))
           (with-connection (list (getf ,db :dbname)
                                  (getf ,db :dbuser)
                                  (getf ,db :dbpass)
                                  (getf ,db :dbhost))
             ,@body)))))

(defmacro select-dao-unique (type &optional (test t) &rest ordering)
  (with-gensyms (dao)
    `(let ((,dao (select-dao ,type ,test ,@ordering)))
       (if (null ,dao)
           nil
           (if (= (length ,dao) 1)
               (first ,dao)
               (error "DAO is not unique"))))))

(defmethod urlenc->lisp (value (type (eql 'date)))
  (handler-case (if (string-equal value +urlenc-false+)
                    nil
                    (parse-date value))
    (error () ;; match all errors
      (error 'http-parse-error
             :http-type type
             :raw-value value))))



;;; ----------------------------------------------------------------------
;;; integration for local-time and cl-postgres
;;; ----------------------------------------------------------------------

(set-local-time-cl-postgres-readers)

(define-timezone "+GREEK-ZONE+" #p"/usr/share/zoneinfo/Europe/Athens")



;;; ------------------------------------------------------------
;;; Date
;;; ------------------------------------------------------------

(define-condition date-parse-error (error)
  ((raw-value :accessor raw-value :initarg :raw-value)))

(defun parse-date (value)
  (handler-case (destructuring-bind (day month year) (mapcar #'parse-integer (split "-|/|\\." value))
                  (encode-timestamp 0 0 0 0
                                    day
                                    month
                                    (if (< year 1000) (+ year 2000) year)
                                    :timezone +utc-zone+))
    (error () ;; match all errors
      (error 'date-parse-error :raw-value value))))

(defmethod lisp->html ((tstamp timestamp))
  (format-timestring nil tstamp
                     :format '((:day 2) #\/ (:month 2) #\/ (:year 4))
                     :timezone *default-timezone*))

(defmethod lisp->urlenc ((tstamp timestamp))
  (url-encode
   (format-timestring nil tstamp
                      :format '((:day 2) #\- (:month 2) #\- (:year 4))
                      :timezone +utc-zone+)))
