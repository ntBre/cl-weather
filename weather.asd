(defpackage :com.bwestbro.weather-system (:use :asdf :cl))
(in-package :com.bwestbro.weather-system)

(defsystem "weather"
  :description "weather package written in common lisp"
  :version "0.0.1"
  :author "Brent R. Westbrook <brent@bwestbro.com>"
  :components
  ((:file "weather"))
  :depends-on (:xmls :drakma :flexi-streams))
