;;; Copyright (C) 2015 Marco Heisig - licensed under GPLv3 or later

(set! define-macro
  (macro
      (lambda (signature . body)
        ((lambda (name arguments)
           `(set! ,name
              (macro
                  (lambda ,arguments
                    ,(cons 'begin body)))))
         (car signature)
         (cdr signature)))))

(define-macro (let bindings . body)
  ((lambda (arguments forms)
     `((lambda ,arguments
         ,@body)
       ,@forms))
   (map car bindings)
   (map cadr bindings)))

(define-macro (define signature . body)
  (if (pair? signature)
      (let ((name (car signature))
            (arguments (cdr signature)))
        `(set! ,name
           (lambda ,arguments ,@body)))
      (let ((name signature))
        `(set! ,name ,@body))))

(define-macro (receive parameters expr . body)
  (let ((initial (map (lambda (x) #f) parameters)))
    `((lambda ,parameters
        (bind! ,parameters ,expr)
        ,@body)
      ,@initial)))

(define-macro (unless condition . body)
  `(if (not ,condition)
       (begin ,@body)))

(define-macro (when condition . body)
  `(if ,condition
       (begin ,@body)))
