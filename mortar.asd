;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

(in-package :cl)

(asdf:defsystem :mortar
  :serial t
  :depends-on (:alexandria
               :cl-ppcre
               :hunchentoot
               :cl-who
               :local-time
               :postmodern
               :cl-postgres+local-time
               :veil
               :bricks)
  :components ((:file "package")
               (:file "db-utils")
               (:file "extensions")))
