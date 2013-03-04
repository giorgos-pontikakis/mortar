;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

(in-package :cl-user)

(defpackage :mortar-asdf
    (:use :cl :asdf))

(in-package :mortar-asdf)

(defsystem :mortar
  :serial t
  :version "1.0.2"
  ;;
  :depends-on (:alexandria
               :cl-ppcre
               :hunchentoot
               :cl-who
               :local-time
               :postmodern
               :cl-postgres+local-time
               (:version :veil "1.0.0")
               (:version :bricks "1.0.3"))
  ;;
  :components ((:file "package")
               (:file "db-utils")
               (:file "extensions")))
