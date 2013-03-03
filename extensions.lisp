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
