(in-package :first-light.example)

;;; Textures

(fl:define-texture sprites (:texture-2d)
  (:data #(:spritesheet)))

;;; Components

(fl:define-component simple-movement ()
  ((transform :default nil)))

(defmethod fl:on-component-initialize ((self simple-movement))
  (with-accessors ((actor fl:actor) (transform transform)) self
    (setf transform (fl:actor-component-by-type actor 'transform))
    (fl.comp:translate transform (m:vec3 -400 0 0) :replace-p t :instant-p t)))

(defmethod fl:on-component-update ((self simple-movement))
  (with-accessors ((context fl:context) (transform transform)) self
    (au:mvlet* ((lx ly (fl.input:get-gamepad-analog (fl:input-data context)
                                                    '(:gamepad1 :left-stick)))
                (rx ry (fl.input:get-gamepad-analog (fl:input-data context)
                                                    '(:gamepad1 :right-stick)))
                (instant-p (zerop (fl:frame-count context))))
      (let ((vec (m:vec3 lx ly 0)))
        (m:* (if (> (m:length vec) 1) (m:normalize vec) vec) 150.0 vec)
        (fl.comp:translate transform
                           (m:+ (m:vec3 -400 0 0) vec)
                           :replace-p t
                           :instant-p instant-p))
      (unless (= rx ry 0.0)
        (let* ((angle (atan (- rx) ry))
               (angle (if (< angle 0)
                          (+ pi (- pi (abs angle)))
                          angle)))
          (fl.comp:rotate transform
                          (m:vec3 0 0 angle)
                          :replace-p t
                          :instant-p instant-p))))))

(fl:define-component shot-mover ()
  ((transform :default nil)
   (velocity :default 0)))

(defmethod fl:on-component-initialize ((self shot-mover))
  (with-accessors ((actor fl:actor) (transform transform)) self
    (setf transform (fl:actor-component-by-type actor 'fl.comp:transform))))

(defmethod fl:on-component-update ((self shot-mover))
  (with-accessors ((context fl:context) (transform transform)
                   (velocity velocity))
      self
    (fl.comp:translate
     transform
     (let ((a (m:normalize (m:vec3 (m:get-column (fl.comp:local transform) 1))))
           (move-delta (* velocity (fl:frame-time context))))
       (m:* a move-delta)))))

(fl:define-component shot-emitter ()
  ((emitter-transform :default nil)))

(defmethod fl:on-component-initialize ((self shot-emitter))
  (with-accessors ((actor fl:actor) (emitter-transform emitter-transform)) self
    (setf emitter-transform (fl:actor-component-by-type
                             actor 'fl.comp:transform))))

(defmethod fl:on-component-update ((self shot-emitter))
  (with-accessors ((context fl:context) (emitter-transform emitter-transform))
      self
    (when (or (fl.input:input-enter-p (fl:input-data context) '(:gamepad1 :a))
              (fl.input:input-enter-p (fl:input-data context) '(:mouse :left)))
      (let* ((parent-model (fl.comp:model emitter-transform))
             (parent-translation (m:get-translation parent-model))
             (parent-rotation (m:quat parent-model))
             (new-actor (fl:make-actor context :display-id "Ship bullet"))
             (transform (fl:make-component context
                                           'fl.comp:transform
                                           :translate parent-translation
                                           :rotate parent-rotation))
             (shot-mover (fl:make-component context 'shot-mover :velocity 1000))
             (sprite (fl:make-component context
                                        'sprite
                                        :spec :spritesheet-data
                                        :name "bullet01"
                                        :frames 2))
             (render (fl:make-component context
                                        'render
                                        :material `(fl.materials:sprite
                                                    ,(au:unique-name '#:sprite)
                                                    :uniforms
                                                    ((:sprite.sampler sprites)))
                                        :mode :sprite)))
        (fl:attach-multiple-components
         new-actor transform shot-mover sprite render)
        (fl:spawn-actor new-actor)
        (%fl::destroy new-actor :ttl 2)))))

;;; Prefabs

(fl:define-prefab "sprite-1" (:library examples)
  (("camera" :copy "/cameras/ortho"))
  ("ship"
   (fl.comp:transform :rotate (m:vec3 0 0 (/ pi -2)))
   (simple-movement)
   (shot-emitter)
   ("ship-body"
    (fl.comp:sprite :spec :spritesheet-data
                    :name "ship29")
    (fl.comp:render :material `(fl.materials:sprite
                                ,(au:unique-name '#:sprite)
                                :uniforms ((:sprite.sampler sprites)))
                    :mode :sprite)
    ("exhaust"
     (fl.comp:transform :translate (m:vec3 0 -140 0))
     (fl.comp:sprite :spec :spritesheet-data
                     :name "exhaust03-01"
                     :frames 8)
     (fl.comp:render :material `(fl.materials:sprite
                                 ,(au:unique-name '#:sprite)
                                 :uniforms ((:sprite.sampler sprites)))
                     :mode :sprite)
     (fl.comp:actions :default-actions '((:type fl.actions:sprite-animate
                                          :duration 0.5
                                          :repeat-p t)))))))

(fl:define-prefab "sprite-2" (:library examples)
  (("camera" :copy "/cameras/ortho"))
  ("plane"
   (fl.comp:transform :scale (m:vec3 2))
   (fl.comp:sprite :spec :spritesheet-data
                   :name "planet04")
   (fl.comp:render :material `(fl.materials:sprite
                               ,(au:unique-name '#:sprite)
                               :uniforms ((:sprite.sampler sprites)))
                   :mode :sprite)
   (fl.comp:actions :default-actions '((:type fl.actions:rotate
                                        :duration 4
                                        :shape m:bounce-in
                                        :repeat-p t)))))