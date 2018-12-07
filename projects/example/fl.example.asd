(asdf:defsystem #:fl.example
  :description "Example scene for first-light."
  :author ("Michael Fiano <michael.fiano@gmail.com>"
           "Peter Keller <psilord@cs.wisc.edu>")
  :maintainer ("Michael Fiano <michael.fiano@gmail.com>"
               "Peter Keller <psilord@cs.wisc.edu>")
  :license "MIT"
  :version "0.1.0"
  :depends-on (#:first-light #:black-tie)
  :pathname "src"
  :serial t
  :components
  ((:file "package")
   (:file "resources")
   (:file "prologue")
   (:file "epilogue")
   (:file "sprite-test")
   (:file "shader-sweep")))
