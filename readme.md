# Simple Tokenizer

WIP

## Installation

```
ros install myaosato/simple-tokenizer
```

## HOW TO USE

```
(ql:quickload :simple-tokenizer)
(simple-tokenizer/simple-tokenizer:def-tokenizer tokenizer
  (:regex "a" :type 'a)
  (:regex "b" :type 'b)
  (:regex "\\s+" :type 'ws :ignore-p t))
(tokenizer "a  b")
=> (#S(TOKEN :str "a" :type 'a) #S(TOKEN :str "b" :type 'b))
```
