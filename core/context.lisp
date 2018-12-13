(in-package :%fl)

(defclass context ()
  ((%core-state :reader core-state
                :initarg :core-state)
   (%project-data :accessor project-data)
   (%settings :reader settings
              :initarg :settings)
   (%active-camera :accessor active-camera
                   :initform nil)
   (%shared-storage-table :reader shared-storage-table
                          :initform (fl.util:dict #'eq))
   (%state :accessor state
           :initform nil)))

(defun make-context (core-state)
  (setf (slot-value core-state '%context)
        (make-instance 'context
                       :core-state core-state
                       :settings (settings core-state))))

(defun total-time (context)
  "Return the total time in seconds that the engine has been running."
  (slot-value (frame-manager (core-state context)) '%total-time))

(defun frame-time (context)
  "Return the amount of time in seconds of the last frame as a REAL."
  (slot-value (frame-manager (core-state context)) '%frame-time))

(defun delta (context)
  "Return the physics update delta. This is :delta from the cfg file."
  (slot-value (frame-manager (core-state context)) '%delta))

;; These functions can use qualify-component. That'll be magic.
(defun ss-href (context component-name namespace &rest keys)
  (let* ((qualified-component-name (qualify-component (core-state context) component-name))
         (metadata-ht-test-fns (cdr (shared-storage-metadata qualified-component-name namespace))))
    (when (null metadata-ht-test-fns)
      (error "Shared storage namespace ~s does not exist for component ~s in package ~s"
             namespace
             component-name
             (if qualified-component-name
                 (package-name (symbol-package qualified-component-name))
                 "[no package: component does not exist!]")))
    (assert (= (length metadata-ht-test-fns) (length keys)))
    (ensure-nested-hash-table (shared-storage-table context)
                              (list* 'eq 'eql metadata-ht-test-fns)
                              (list* qualified-component-name namespace keys))
    (apply #'fl.util:href
           (shared-storage-table context)
           (list* qualified-component-name namespace keys))))

(defun (setf ss-href) (new-value context component-name namespace &rest keys)
  (let* ((qualified-component-name (qualify-component (core-state context) component-name))
         (metadata-ht-test-fns (cdr (shared-storage-metadata qualified-component-name namespace))))
    (assert (= (length metadata-ht-test-fns) (length keys)))
    (ensure-nested-hash-table (shared-storage-table context)
                              (list* 'eq 'eql metadata-ht-test-fns)
                              (list* qualified-component-name namespace keys))
    (apply #'(setf fl.util:href)
           new-value
           (shared-storage-table context)
           (list* qualified-component-name namespace keys))))

(defun %lookup-form-to-bindings (lookup-form)
  "Convert a LOOKUP-FORM with form (a b c ... z) to a set of gensymed bindings like ((#:G0 a) (#:G1
b) (#:G2 c) ... (#:G26 z)) and return it."
  (mapcar
   (lambda (element)
     (list (gensym) element))
   lookup-form))

(defun %generate-ss-get/set (context bindings body)
  "While there are bindings to perform, strip one off, build a lexical environemt for it that will
set it into the shared-storatge in CONTEXT, and keep expanding with further bindings. When done,
emit the body in the final and most dense lexical scope."
  (if (null bindings)
      `(progn ,@body)
      (destructuring-bind (lexical-var presentp-var lookup-form cache-value-form) (first bindings)
        (let* ((lookup-binding-forms (%lookup-form-to-bindings lookup-form))
               (lookup-args (mapcar #'first lookup-binding-forms)))
          `(let ,lookup-binding-forms
             (fl.util:mvlet ((,lexical-var ,presentp-var (ss-href ,context ,@lookup-args)))
               (unless ,presentp-var
                 (setf ,lexical-var ,cache-value-form
                       (ss-href ,context ,@lookup-args) ,lexical-var))
               ,(%generate-ss-get/set context (rest bindings) body)))))))

(defmacro with-shared-storage ((context-var context-form) cache-bindings &body body)
  "Short Form for shared storage access."
  `(let ((,context-var ,context-form))
     ,(%generate-ss-get/set context-var cache-bindings body)))