(uiop/package:define-package :simple-tokenizer/simple-tokenizer
                             (:nicknames :s-tokenizer) (:use :cl) (:shadow)
                             (:import-from :cl-ppcre :scan)
                             (:export :def-tokenizer) (:intern))
(in-package :simple-tokenizer/simple-tokenizer)
;;don't edit above

(defstruct token
  (str "")
  (type nil))


(defstruct token-info
  (token (make-token))
  (pos 0)
  (ignore-p nil))


(defstruct (token-getter (:constructor %make-token-getter) (:print-function print-token-getter))
  (func)
  (regex)
  (type)
  (ignore-p))

(defun print-token-getter (token-getter stream depth)
  (declare (ignore depth))
  (format stream "#<TOKEN-GETTER :REGEX ~A :TYPE ~A :IGNORE-P ~A>" 
          (token-getter-regex token-getter)
          (token-getter-type token-getter)
          (token-getter-ignore-p token-getter)))

(defun get-result (result-of-scan target)
  (subseq target (first result-of-scan) (second result-of-scan)))
  
(defun %token-getter (target pos &key (regex ".") type ignore-p)
  (let ((result (multiple-value-list (scan regex target :start pos))))
    (if (and (first result) (= (first result) pos))
        (make-token-info :token (make-token :str (get-result result target) 
                                            :type type)
                         :pos (second result) 
                         :ignore-p ignore-p)
        nil)))

(defun make-token-getter (&key regex type ignore-p)
  (%make-token-getter :func (lambda (target pos) 
                              (%token-getter target pos :regex regex :type type :ignore-p ignore-p))
                      :regex regex
                      :type type
                      :ignore-p ignore-p))

(defun get-token (target pos &optional token-getters)
  (if (= pos (length target)) (return-from get-token nil))
  (unless token-getters (return-from get-token nil))
  (let ((token-info (funcall (token-getter-func (car token-getters)) target pos)))
    (if token-info
        token-info
        (get-token target pos (cdr token-getters)))))

(defun tokenizer (target &optional (pos 0) tokens token-getters)
  (let ((token-info (get-token target pos token-getters)))
    (if token-info
        (if (token-info-ignore-p token-info)
            (tokenizer target (token-info-pos token-info) tokens token-getters)
            (tokenizer target (token-info-pos token-info) (cons (token-info-token token-info) tokens) token-getters))
        (reverse tokens))))
        
(defun make-tokenizer (specifiers)
  (let ((token-getters))
    (dolist (spec specifiers)
      (push (make-token-getter :regex (getf spec :regex) 
                               :type (getf spec :type) 
                               :ignore-p (getf spec :ignore-p)) 
            token-getters))
    (lambda (target) (tokenizer target 0 nil (reverse token-getters)))))
  
(defmacro def-tokenizer (symbol &rest specifiers)
  `(progn 
     (setf (symbol-function (intern (string ',symbol)))
           (,'make-tokenizer ',specifiers))
     ',symbol))
