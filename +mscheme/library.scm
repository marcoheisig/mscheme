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

(define-macro (define signature . body)
  ((lambda (name arguments)
     `(set! ,name
        (lambda ,arguments
          ,@body)))
   (car signature)
   (cdr signature)))

(define-macro (let bindings . body)
  ((lambda (arguments forms)
     `((lambda ,arguments
         ,@body)
       ,@forms))
   (map car bindings)
   (map cadr bindings)))
