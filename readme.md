# Simple Tokenizer

```
ros install myaosato/simple-tokenizer
```

WIP

```
(register :regex "a" :type 'a)
(register :regex "b" :type 'b)
(register :regex "\\s+" :type 'ws :ignore-p t)

(tokenizer "a  b")
=> (#S(TOKEN :str "a" :type 'a) #S(TOKEN :str "b" :type 'b))
```
