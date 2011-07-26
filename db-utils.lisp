(in-package :mortar)


;;; Utilities

(defmacro with-db (&optional database &body body)
  (with-gensyms (db)
    `(let ((,db (or ,database (database (package-webapp)))))
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
