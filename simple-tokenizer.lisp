(uiop/package:define-package :simple-tokenizer/simple-tokenizer (:nicknames)
                             (:use :cl) (:shadow)
                             (:import-from :cl-ppcre :scan)
                             (:export :tokenizer :register) (:intern))
(in-package :simple-tokenizer/simple-tokenizer)
;;don't edit above

(defstruct token
  (str "")
  (type nil))


(defstruct token-info
  (token (make-token))
  (pos 0)
  (ignore-p nil))
  

(defun get-result (result-of-scan target)
  (subseq target (first result-of-scan) (second result-of-scan)))
  
(defun token-getter (target pos &key (regex ".") type ignore-p)
  (let ((result (multiple-value-list (scan regex target :start pos))))
    (if (and (first result) (= (first result) pos))
        (make-token-info :token (make-token :str (get-result result target) 
                                            :type type)
                         :pos (second result) 
                         :ignore-p ignore-p)
        nil)))

(defun make-token-getter (&key regex type ignore-p)
  (lambda (target pos) 
    (token-getter target pos :regex regex :type type :ignore-p ignore-p)))

(defvar *token-getters* nil)

(defun register (&key regex type ignore-p)
  (push (make-token-getter :regex regex :type type :ignore-p ignore-p)
        *token-getters*))

(defun get-token (target pos &optional (token-getters *token-getters*))
  (if (= pos (length target)) (return-from get-token nil))
  (unless token-getters (return-from get-token nil))
  (let ((token-info (funcall (car token-getters) target pos)))
    (if token-info
        token-info
        (get-token target pos (cdr token-getters)))))

(defun tokenizer (target &optional (pos 0) tokens)
  (let ((token-info (get-token target pos)))
    (if token-info
        (if (token-info-ignore-p token-info)
            (tokenizer target (token-info-pos token-info) tokens)
            (tokenizer target (token-info-pos token-info) (cons (token-info-token token-info) tokens)))
        (reverse tokens))))
        
        
  
  
  
