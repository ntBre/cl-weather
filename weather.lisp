(defpackage :com.bwestbro.weather
  (:use :common-lisp))

(in-package :com.bwestbro.weather)

;; turn off string-elision length
;; (setf (cdr (assoc 'slynk:*string-elision-length* slynk:*slynk-pprint-bindings*)) nil)

(defparameter *hourly-weather-url*
  "https://forecast.weather.gov/MapClick.php?lat=34.37&lon=-89.52&FcstType=digitalDWML")

(defun get-weather ()
  "retrieve the weather forcast from *HOURLY-WEATHER-URL*, convert it
  to a string, and return the parsed XML"
  (xmls:parse
   (flexi-streams:octets-to-string
    (drakma:http-request *hourly-weather-url*))))
