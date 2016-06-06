(asdf:defsystem sb-httpd-nonblock
    :version "0"
    :description "Simple Common Lisp HTTP server with send event support, single-threaded for use on raspberry pi."
    :maintainer " <martin@localhost>"
    :author " <martin@localhost>"
    :licence "GPL"
    :depends-on (sb-bsd-sockets)
    :serial t
    ;; components likely need manual reordering
    :components ((:file "nserv"))
    ;; :long-description ""
    )
