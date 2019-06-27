(in-package #:%first-light)

(defmacro with-continue-restart (report &body body)
  `(let* ((debugger-entry-time)
          (previous-hook *debugger-hook*)
          (#+sbcl sb-ext:*invoke-debugger-hook*
           #-sbcl *debugger-hook
           (lambda (condition hook)
             (declare (ignore hook))
             (setf debugger-entry-time (get-time))
             (when previous-hook
               (funcall previous-hook condition previous-hook)))))
     (restart-case (progn ,@body)
       (continue ()
         :report ,report
         (with-slots (%pause-time) (frame-manager *core-debug*)
           (when debugger-entry-time
             (setf %pause-time (- (get-time) debugger-entry-time))))))))

(defun compile-live-coding-functions ()
  (let ((repl-package (find-if #'find-package '(:slynk :swank))))
    (case repl-package
      ((:slynk :swank)
       (compile 'find-lisp-repl
                `(lambda ()
                   (or ,(a:ensure-symbol "*EMACS-CONNECTION*" repl-package)
                       (,(a:ensure-symbol "DEFAULT-CONNECTION"
                                          repl-package)))))
       (compile 'setup-lisp-repl
                (ecase repl-package
                  (:slynk
                   `(lambda ()
                      ,(when (find-package "SLYNK-MREPL")
                         `(,(a:ensure-symbol "SEND-PROMPT" "SLYNK-MREPL")
                           (find (bt:current-thread)
                                 (,(a:ensure-symbol "CHANNELS" repl-package))
                                 :key #',(a:ensure-symbol "CHANNEL-THREAD"
                                                          repl-package))))))
                  (:swank
                   (constantly nil))))
       (compile 'update-lisp-repl
                `(lambda ()
                   (a:when-let ((repl (find-lisp-repl)))
                     (with-continue-restart "REPL"
                       (,(a:ensure-symbol "HANDLE-REQUESTS" repl-package)
                        repl t))))))
      (t (setf (symbol-function 'setup-lisp-repl) (constantly nil)
               (symbol-function 'update-lisp-repl) (constantly nil))))))

(defun setup-live-coding ()
  (compile-live-coding-functions)
  (funcall 'setup-lisp-repl))

(defun live-coding-update ()
  (funcall 'update-lisp-repl))
