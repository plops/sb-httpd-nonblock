(ql:quickload :cl-who)
(ql:quickload :sb-httpd-nonblock)

(in-package :nserv)

(defparameter *s* (webserver-open-socket))

(webserver-event-loop *s*)

(send-event-to-all-clients "huhu2")

;; how to use cl-who to generate svg:
;; https://lispnews.wordpress.com/2013/02/08/generating-svg-from-lisp-is-easy/



(defmacro with-svg (&body body)
  (let ((s (gensym)))
   `(with-output-to-string (,s)
      ;(format ,s "<?xml version=\"1.0\" standalone=\"yes\"?>")
      (who:with-html-output
	  (,s nil
;	      :prologue "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">"
	     :indent nil)
	,@body))))

#+nil
(with-svg 
    (:svg :width "4in" :height "3in" :version "1.1"
	  :xmlns "http://www.w3.org/2000/svg" :|xmlns:xlink| "http://www.w3.org/1999/xlink"
	  (:desc "This graphic links to an external image")

	  (:image :x "200" :y "200" :width "100px" :height "100px"
		  :|xlink:href| "myimage.png"
		  (:title "My image"))))

;; => "<?xml version=\"1.0\" standalone=\"yes\"?>

;; <!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">

;; <svg width='4in' height='3in' version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'>
;;   <desc>This graphic links to an external image
;;   </desc>
;;   <image x='200' y='200' width='100px' height='100px' xlink:href='myimage.png'>
;;     <title>My image
;;     </title>
;;   </image>
;; </svg>"




(send-event-to-all-clients
 (concatenate 'string
  (cl-who:with-html-output-to-string (s)
    (:b "hello"))
  (with-svg 
    (:svg :width "100" :height "100" :version "1.1"
	  :xmlns "http://www.w3.org/2000/svg" :|xmlns:xlink| "http://www.w3.org/1999/xlink"
	  (:desc "This is a test image")

	  (:circle :cx "50" :cy "50" :r "40" :stroke "green" :stroke-width "4" :fill "yellow")
	  (:polyline :points "20,20 40,25 60,40 80,120 120,140 200,180"
		     :style "fill:none;stroke:black;stroke-width:3")))))


(dotimes (j 1000)
  (sleep .01)
  (send-event-to-all-clients
   (with-svg 
     (:svg :width "950" :height "500" :version "1.1"
	   :xmlns "http://www.w3.org/2000/svg" :|xmlns:xlink| "http://www.w3.org/1999/xlink"
	   (:polyline :points (flet ((sca (x) (floor (* x 80))))
			       (format nil "~{~{~a~} ~}"
				       (loop for i below 50 collect (let ((x (/ i 20s0)))
								       (list (sca x) "," (sca (+ 1 (sin (+ (/ j 20s0)  x)))))))))
		      :style "fill:none;stroke:black;stroke-width:2")))))

(dotimes (j 1000)
  (sleep .01)
  (send-event-to-all-clients
   (concatenate
    'string
    (cl-who:with-html-output-to-string (sm)
      (:table
       (loop for i below 25 by 5 do
	    (cl-who:htm (:tr
		  (loop for j from i below (+ i 5)
		     do
		       (cl-who:htm (:td
			     (if (= j 11)
				 (cl-who:htm (:font :color "red"
					     (cl-who:fmt "~a" (get-internal-run-time))))
				 (cl-who:fmt "~a" j))))))))))
    (with-svg 
      (:svg :width "950" :height "500" :version "1.1"
	    :xmlns "http://www.w3.org/2000/svg" :|xmlns:xlink| "http://www.w3.org/1999/xlink"
	    (:polyline :points (flet ((sca (x) (floor (* x 80))))
				 (format nil "~{~{~a~} ~}"
					 (loop for i below 50 collect (let ((x (/ i 20s0)))
									(list (sca x) "," (sca (+ 1 (sin (+ (/ j 20s0)  x)))))))))
		       :style "fill:none;stroke:black;stroke-width:2"))))))

