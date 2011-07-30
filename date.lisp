(in-package :mortar)



(defun parse-date (value)
  (destructuring-bind (day month year) (mapcar #'parse-integer (split "-|/|\\." value))
    (encode-date (if (< year 1000) (+ year 2000) year)
                 month
                 day)))

;;; Extensions to veil and bricks

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


;;; Misc

(defun see-other (url)
  (redirect url :code +http-see-other+))


(defmacro with-form (url &body body)
  (let* ((pos (position-if #'keywordp url))
         (hidden (if pos (subseq url pos) nil)))
    `(display (make-instance 'form
                             :action ,(subseq url 0 pos)
                             :reqtype (request-type (find-page ',(first url) (current-acceptor)))
                             :hidden (list ,@hidden)
                             :body (html ()
                                     ,@body)))))




;;; ------------------------------------------------------------
;;; MESSENGER
;;; ------------------------------------------------------------

(defclass messenger (widget)
  ((messages   :accessor messages   :initarg :messages)
   (parameters :accessor parameters :initarg :parameters))
  (:default-initargs :id nil))

(defmethod display ((messenger messenger) &key)
  (flet ((get-message (param messages)
           (if-let (msg-plist (second (assoc (name (attributes param)) messages)))
             ;; if the name of the parameter is not found, don't print any messages
             (if-let (tail (member (error-type param) msg-plist))
               ;; Use member to extract message from plist instead of
               ;; getf, to be able to have nil as a value (the cadr of
               ;; tail may be nil) and not get the fallback
               (cadr tail)
               (string-downcase (error-type param)))
             nil)))
    (unless (every #'validp (parameters messenger))
      (with-html
        (:ul :id (id messenger)
             (iter (for p in (parameters messenger))
                   (unless (validp p)
                     (when-let (msg (get-message p (messages messenger)))
                       (htm (:li :class (css-class messenger)
                                 (str msg)))))))))))

(defun messenger (messages parameters &rest instance-initargs)
  (display (apply #'make-instance 'messenger
                  :messages messages
                  :parameters parameters
                  instance-initargs)))