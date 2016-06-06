(ql:quickload :sb-httpd-nonblock)

(in-package :nserv)

(defparameter *s* (webserver-open-socket))

(webserver-event-loop *s*)

(send-event-to-all-clients "huhu2")
