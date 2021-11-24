(defpackage :com.bwestbro.weather
  (:use :common-lisp))

(in-package :com.bwestbro.weather)

;; FcstType=digital gives table and =graphical gives graphs
(defparameter *hourly-weather-url*
  "https://forecast.weather.gov/MapClick.php?lat=34.37&lon=-89.52&FcstType=digitalDWML")

(defun get-weather ()
  "retrieve the weather forcast from *HOURLY-WEATHER-URL*, convert it
  to a string, and return the parsed XML"
  (xmls:parse
   (flexi-streams:octets-to-string
    (drakma:http-request *hourly-weather-url*))))

(defparameter *weather* (get-weather))

;; document -> data -> time-layout -> start-valid-time
(defun extract-time (xml-weather-data)
  "extract the datetime string from XML-WEATHER-DATA"
  (mapcar #'(lambda (tag) (car (xmls:node-children tag)))
	  (remove-if-not #'(lambda (n) (string-equal
					(xmls:node-name n)
					"start-valid-time"))
			 (xmls:node-children
			  (xmls:xmlrep-find-child-tag
			   "time-layout"
			   (xmls:xmlrep-find-child-tag "data" xml-weather-data))))))

(defun extract-hourly-temp (xml-weather-data)
  (mapcar #'(lambda (node)
	      (read-from-string
	       (car (xmls:node-children node))))
	  (xmls:node-children
	   (car
	    (remove-if-not #'(lambda (x)
			       (string-equal (xmls:xmlrep-attrib-value "type" x)
					     "hourly"))
			   (xmls:xmlrep-find-child-tags
			    "temperature"
			    (xmls:xmlrep-find-child-tag
			     "parameters"
			     (xmls:xmlrep-find-child-tag "data" xml-weather-data))))))))

(with-open-file (out "data" :direction :output :if-exists :supersede)
  (mapcan #'(lambda (x) (format out "~a ~a~%" (car x) (cadr x)))
	  (let ((weather (get-weather)))
	    (mapcar #'list
		    ;; remove timezone information
		    (mapcar #'(lambda (x) (cl-ppcre:regex-replace
					   "-0\\d:00" x ""))
		    (extract-time weather))
		    (extract-hourly-temp weather)))))

(defun plot (filename)
  "plots time-series data using `plot.sh` with FILENAME as the first
argument"
  (uiop:run-program (concatenate 'string "sh plot.sh " filename)))

(defun cat (filename)
  (with-open-file (in filename :direction :input)
    (loop for line = (read-line in nil nil)
	  while line do
	    (format t "~a~%" line))))
