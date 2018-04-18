# Simple Tokenizer

```
ros install myaosato/simple-tokenizer
```

WIP

```
(defvar tokenizer 
  (make-tokenizer '((:regex "a" :type 'a)
                    (:regex "b" :type 'b)
                    (:regex "\\s+" :type 'ws :ignore-p t))))
(funcall tokenizer "a  b")
=> (#S(TOKEN :str "a" :type 'a) #S(TOKEN :str "b" :type 'b))
```
