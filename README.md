# sb-httpd-nonblock

Very simple single threaded web server to run a 'server sent
event'-based web interface on a Raspberry Pi.


## usage:

```webserver-open-socket => socket```

Listens on port 8888.

```webserver-close-socket socket```

Close SOCKET.

```webserver-event-loop socket```

Start serving requests. This event loop also handles swank requests to
keep slime responsive in the single threaded environment. The loop can
be aborted by setting `nserv:*serve-requests` to `nil`.  Two files are
served: / returns HTML with minimal Javascript to register an event
handler on /event. All client connections for /event are placed into
an internal list (nserv::*client-wanting-event*) so that they can be
served with updates using `send-event-to-all-clients`.


```send-event-to-all-clients payload-string```

Sends the PAYLOAD-STRING to all clients that opened a connection on /event.


## example:

Clone the repo into local-projects directory:
```
cd ~/quicklisp/local-projects
git clone https://github.com/plops/sb-httpd-nonblock
```

```common-lisp
(ql:quickload :sb-httpd-nonblock)
(in-package :nserv)
(defparameter *s* (webserver-open-socket))
(webserver-event-loop *s*)
;; connect with webbrowser on host:8888
(send-event-to-all-clients "huhu")
```