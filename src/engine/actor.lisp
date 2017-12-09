(in-package :fl.core)

(defclass actor ()
  ((%id :reader id
        :initarg :id)
   (%state :accessor state
           :initarg :state
           :initform :initialize)
   (%components :reader components
                :initform (make-hash-table))
   (%components-by-type :reader components-by-type
                        :initform (make-hash-table))
   (%scene :accessor scene
           :initarg :scene)
   (%core-state :reader core-state
                :initarg :core-state)))

(defmethod print-object ((object actor) stream)
  (print-unreadable-object (object stream :type t)
    (format stream "~a" (id object))))

(defun make-actor (context &rest args)
  (apply #'make-instance 'actor :core-state (core-state context) args))

(defun add-component (actor component)
  (unless (actor component)
    (setf (actor component) actor))
  (setf (gethash component (components actor)) component)
  (push component (gethash (component-type component)
                           (components-by-type actor))))

(defun add-multiple-components (actor components)
  (dolist (component components)
    (add-component actor component)))

(defun actor-components-by-type (actor component-type)
  "Get a list of all components of type COMPONENT-TYPE for the given ACTOR."
  (gethash component-type (components-by-type actor)))

(defun actor-component-by-type (actor component-type)
  "Get the first component of type COMPONENT-TYPE for the given ACTOR.
Returns T as a secondary value if there exists more than one component of that
type."
  (let* ((qualified-type (qualify-component (core-state actor) component-type))
         (components (actor-components-by-type actor qualified-type)))
    (values (first components)
            (> (length components) 1))))

;; TODO: This uses ensure-symbol a lot because it wants to know about the
;; fl.comp.transform:transform component. However, that package is not
;; available at read time for this code. Think about a better way, if any,
;; to do this operation.
(defun spawn-actor (actor context &key (parent :universe))
  "Take the ACTOR and place into the initializing db's and view's in the
CORE-STATE. The actor is not yet in the scene and the main loop protocol will
not be called on it or its components. If keyword argument :PARENT is supplied
it is an actor reference which will be the parent of the spawning actor. It
defaults to :universe, which means make this actor a child of the universe
actor."

  (let* ((core-state (core-state context))
         (sym/transform (ensure-symbol 'transform 'fl.comp.transform))
         (sym/add-child-func (ensure-symbol 'add-child 'fl.comp.transform))
         (sym/parent-func (ensure-symbol 'parent 'fl.comp.transform))
         (actor-transform (actor-component-by-type actor sym/transform)))

    (cond
      ((eq parent :universe)
       ;; TODO: This isn't exactly correct, but will work in most cases.
       ;; Namely, it works in the scene dsl expansion since we add children
       ;; before spawning the actors. We may be able to fix the scene dsl
       ;; expansion to just supply the :parent keyword to spawn-actor instead
       ;; and forgo the add-child calls there. Usually, when a user
       ;; calls SPAWN-ACTOR in their code, they will either leave :parent
       ;; at default, or already have an actor to reference as the parent.
       (unless (funcall sym/parent-func actor-transform)
         (funcall sym/add-child-func
                  (actor-component-by-type (scene-tree core-state)
                                           sym/transform)
                  (actor-component-by-type actor sym/transform))))
      ((typep parent 'actor)
       (funcall sym/add-child-func
                (actor-component-by-type parent sym/transform)
                (actor-component-by-type actor sym/transform)))
      ((null parent)
       ;; NOTE: We're in %make-scene-tree, do nothing since we're making the
       ;; universe!
       nil)

      (t
       (error "Cannot parent actor ~A to unknown parent ~A" actor parent)))

    (setf (gethash actor (actor-preinitialize-db core-state)) actor)
    (maphash
     (lambda (k v)
       (declare (ignore k))
       (setf (type-table
              (canonicalize-component-type (component-type v) core-state)
              (component-preinitialize-by-type-view core-state))
             v))
     (components actor))))

(defun actor/preinit->init (core-state actor)
  #++(format t "actor/preinit->init: ~A~%" actor)
  (remhash actor (actor-preinitialize-db core-state))
  (setf (gethash actor (actor-initialize-db core-state)) actor))

(defun actor/init->active (core-state actor)
  #++(format t "actor/init->active: ~A~%" actor)
  (remhash actor (actor-initialize-db core-state))
  (setf (state actor) :active
        (gethash actor (actor-active-db core-state)) actor))


;; TODO: This is not finished.
(defun destroy-actor (actor context &key (ttl 0.0))
  (setf ttl (if (< ttl 0) 0 ttl))
  (let ((core-state (core-state context)))
    ;; TODO: wander down the components and pre-destroy them too.
    (setf (state actor) :destroy
          (gethash actor (actor-pre-destroy-view core-state)) actor)))