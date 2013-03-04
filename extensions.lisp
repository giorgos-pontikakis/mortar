(in-package :mortar)


;;; EXTENSIONS TO VEIL AND BRICKS



;;; ------------------------------------------------------------
;;; Convenience
;;; ------------------------------------------------------------

(defun see-other (url)
  (redirect url :code +http-see-other+))


(defmacro with-form (url &body body)
  (let* ((pos (position-if #'keywordp url))
         (hidden (if pos (subseq url pos) nil)))
    `(display (make-instance 'form
                             :action ,(subseq url 0 pos)
                             :reqtype (request-type (find-page ',(first url) (default-webapp)))
                             :hidden (list ,@hidden)
                             :body (html ()
                                     ,@body)))))



;;; ------------------------------------------------------------
;;; Messenger widget
;;; ------------------------------------------------------------

(defclass messenger (widget)
  ((messages   :accessor messages   :initarg :messages)
   (parameters :accessor parameters :initarg :parameters))
  (:default-initargs :id nil))

(defmethod display ((messenger messenger) &key)
  (flet ((get-message (param messages)
           (if-let (msg-plist (second (assoc (parameter-name (attributes param)) messages
                                             :test #'member :key #'ensure-list)))
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
          (mapc (lambda (p)
                  (unless (validp p)
                    (when-let (msg (get-message p (messages messenger)))
                      (htm (:li :class (css-class messenger)
                             (str msg))))))
                (parameters messenger)))))))

(defun messenger (messages parameters &rest instance-initargs)
  (display (apply #'make-instance 'messenger
                  :messages messages
                  :parameters parameters
                  instance-initargs)))
