;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

(in-package :cl)

(asdf:defsystem :mortar
  :serial t
  :depends-on (:iterate
                :alexandria
                :cl-ppcre
                :hunchentoot
                :cl-who
                :postmodern
                :simple-date
                :veil
                :bricks)
  :components ((:file "package")
               (:file "db-utils")
               (:file "extensions")))
