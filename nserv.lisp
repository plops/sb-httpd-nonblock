(require :sb-bsd-sockets)


(defpackage :nserv
  (:use :cl :sb-bsd-sockets)
  (:export
   #:webserver-open-socket
   #:webserver-close-socket
   #:*client-wanting-event*
   #:send-event-to-all-clients
   #:*serve-requests*
   #:webserver-event-loop))
(in-package :nserv)

(defun webserver-open-socket ()
  (let ((s (make-instance 'inet-socket :type :stream :protocol :tcp)))
    (setf (non-blocking-mode s) t)
    (setf (sockopt-reuse-address s) t)
    (socket-bind s (make-inet-address "127.0.0.1") 8888)
    (socket-listen s 5)
    s))


(defun webserver-close-socket (s)
  (socket-close s))

(defparameter *client-wanting-event* nil)

(defun send-event-to-all-clients (payload-string)
 (loop for v in *client-wanting-event* do
      (handler-case
	  (progn 
	    (format t "sending event to ~a~%" v)
	    (format v
		    "data: ~a~C~C~C~C"
		    payload-string
		    #\return #\linefeed #\return #\linefeed))
	(sb-int:simple-stream-error ()
	  (format t "delete ~a~%" v)
	  (setf *event* (set-difference *event* (list v)))))))

#+nil
(dotimes (I 190)
  (sleep .01)
  (send-event-to-all-clients (format nil "~a" (get-internal-run-time))))


(defun update-swank ()
    (restart-case
	(let ((connection (or swank::*emacs-connection*
			      (swank::default-connection))))
	  (when connection
	    (swank::handle-requests connection t)))
      (continue () :report "Continuable: Continue")))

(defparameter *serve-requests* nil)
(defparameter *serve-requests* t)


(defun webserver-event-loop (s)
 (loop while *serve-requests* do
      (update-swank)
      (let ((s (socket-accept s)))
	(if (null s)
	    (progn (format t ".") (force-output)
		   (sleep .1))
	    (let ((str (socket-make-stream s
					   :output t
					   :input t
					   :element-type 'character
					   :buffering :none
					   :auto-close t
					   :serve-events t)))
	      (prog1
		  (let ((req  (loop while (listen str) collect
				   (read-line str))))
		    (cond
		      ((string= (first req) "GET / HTTP/1.1")
		       (format t "serve /~%")
		       (force-output)
		       (format str "HTTP/1.1 200 OK~%Content-type: text/html~%~%")
		       (format
			str
			"<html>
<body>
<link rel=\"icon\" href=\"data:;base64,iVBORw0KGgo=\">
<div id='feed'></div>
</body>
<script type='text/javascript'>
<!--
window.onload=function(){
var source = new EventSource('event');
source.addEventListener('message',function(e){
//  console.log(e.data);
  var s=document.getElementById('feed');
  s.innerHTML=e.data;
    },false);
}
//-->
</script>	   
</html>")
		       (close str))
		      ((string= (first req) "GET /event HTTP/1.1")
		       (format str "HTTP/1.1 200 OK~%Content-type: text/event-stream~%~%")
		       (format t "serve /event~%")
		       (force-output)
		       (format str "data: ~a~C~C~C~C"
			       (get-internal-real-time)
			       #\return #\linefeed #\return #\linefeed)
		       (push str *client-wanting-event*)))
		    req)))))))

