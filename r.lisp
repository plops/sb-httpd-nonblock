#+nil
(setf sb-impl::*default-external-format* :UTF-8)

(ql:quickload :cl-react)
(ql:quickload :sb-httpd-nonblock)

(in-package :nserv)

(defparameter *s* (webserver-open-socket))

#+nil
(webserver-close-socket *s*)

(defparameter *css-style* "body {
    background-color: lightblue;
}

h1 {
    color: navy;
    margin-left: 20px;
}")

(defparameter *react-js*
 (with-open-file (s "react.js")
   (let ((a (make-array (file-length s) :element-type 'char)))
     (read-sequence a s)
     a)))
(defparameter *react-dom-js*
 (with-open-file (s "react-dom.js")
   (let ((a (make-array (file-length s) :element-type 'char)))
     (read-sequence a s)
     a)))

(defparameter *browser-js*
 (with-open-file (s "browser.min.js")
   (let ((a (make-array (file-length s) :element-type 'char)))
     (read-sequence a s)
     (subseq a 1 (position 0 a)))))

#+nil
(write-sequence *browser-js* *standard-output*)

(defparameter *js-script* (concatenate 'string *react-js* *react-dom-js*
				       *browser-js* 
				       (cl-react:build)))

;; <script src=\"build/react.js\"></script>
;;     <script src=\"build/react-dom.js\"></script>


;;     <script type='application/javascript'>
;; <!--
;; window.onload=function(){
;; var source = new EventSource('event');
;; source.addEventListener('message',function(e){
;;   //console.log(e.data);
;;   var s = document.body;
;;   s.innerHTML=e.data;
;;     },false);
;; }
;; //-->
;;     </script>	   


(defparameter *index-html* "<!DOCTYPE html>
<html>
  <head>
    <meta charset=\"UTF-8\" />
    <title>Hello React!</title>
    <link rel=\"icon\" href=\"data:;base64,iVBORw0KGgo=\">
    <link rel=\"stylesheet\" type=\"text/css\" href=\"mystyle.css\">
    <script src=\"myscript.js\"></script>
  </head>
  <body>
    <div id=\"example\"></div>
    <script type=\"text/babel\">
      ReactDOM.render(
        <h1>Hello, world!</h1>,
        document.getElementById('example')
      );
    </script>
  </body>
</html>
")



(webserver-event-loop *s*)
#+nil
(setf *serve-requests* (not *serve-requests*))

(send-event-to-all-clients "tesst2")




(ps:ps 
  (psx 
    (:a :href "http://www.google.com"
      (:span :class "text-green" "Click here!"))))
