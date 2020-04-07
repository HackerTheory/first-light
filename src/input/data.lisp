(in-package #:virality.engine)

(defclass input-data ()
  ((%gamepad-instances :reader gamepad-instances
                       :initform (u:dict #'eq))
   (%gamepad-ids :accessor gamepad-ids
                 :initform (u:dict #'eq))
   (%detached-gamepads :accessor detached-gamepads
                       :initform nil)
   (%entering :accessor entering
              :initform (u:dict #'eq))
   (%exiting :accessor exiting
             :initform (u:dict #'eq))
   (%states :reader states
            :initform (u:dict #'equal))))

(defun make-input-data (core)
  (let ((input-data (make-instance 'input-data))
        (motion-state (make-mouse-motion-state)))
    (setf (u:href (states input-data) '(:mouse :motion)) motion-state
          (slot-value core '%input-data) input-data)))
