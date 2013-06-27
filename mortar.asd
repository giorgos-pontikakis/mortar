;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

(in-package :cl-user)

(defpackage :mortar-asdf
  (:use :cl :asdf))

(in-package :mortar-asdf)

(defsystem :mortar
  :serial t
  :version "1.1.0"
  ;;
  :depends-on (:alexandria
               :cl-ppcre
               :hunchentoot
               :cl-who
               :local-time
               :postmodern
               :cl-postgres+local-time
               (:version :veil "1.1.0")
               (:version :bricks "2.0.0"))
  ;;
  :components ((:file "package")
               (:file "db-utils")
               (:file "extensions")))
