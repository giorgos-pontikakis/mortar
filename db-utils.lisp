(in-package :mortar)


;;; ------------------------------------------------------------
;;; Utilities
;;; ------------------------------------------------------------

(defmacro with-db (&optional db-connection-spec &body body)
  (with-gensyms (db)
    `(let ((,db (or ,db-connection-spec (db-connection-spec (default-acceptor)))))
       (with-connection (list (getf ,db :dbname)
                              (getf ,db :dbuser)
                              (getf ,db :dbpass)
                              (getf ,db :dbhost))
         ,@body))))

(defmacro select-dao-unique (type &optional (test t) &rest ordering)
  (with-gensyms (dao)
    `(let ((,dao (select-dao ,type ,test ,@ordering)))
       (if (null ,dao)
           nil
           (if (= (length ,dao) 1)
               (first ,dao)
               (error "DAO is not unique"))))))



;;; ------------------------------------------------------------
;;; Date
;;; ------------------------------------------------------------

(define-condition date-parse-error (error)
  ((raw-value :accessor raw-value :initarg :raw-value)))

(defun parse-date (value)
  (handler-case (destructuring-bind (day month year) (mapcar #'parse-integer (split "-|/|\\." value))
                  (encode-date (if (< year 1000) (+ year 2000) year)
                               month
                               day))
    (error () ;; match all errors
      (error 'date-parse-error :raw-value value))))

(defmethod urlenc->lisp (value (type (eql 'date)))
  (handler-case (if (string-equal value +urlenc-false+)
                    nil
                    (parse-date value))
    (error () ;; match all errors
      (error 'http-parse-error
             :http-type type
             :raw-value value))))

(defmethod lisp->html ((value date))
  (multiple-value-bind (year month day) (decode-date value)
    (format nil "~A/~A/~A" day month year)))

(defmethod lisp->urlenc ((value date))
  (multiple-value-bind (year month day) (decode-date value)
    (url-encode (format nil "~A-~A-~A" day month year))))
