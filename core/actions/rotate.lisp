(in-package :first-light.actions)

(defmethod on-action-update (action (type (eql 'rotate)))
  (let* ((transform (fl.comp:transform (renderer (manager action))))
         (attrs (attrs action))
         (angle (or (fl.util:href attrs :angle) (* pi 2)))
         (step (fl.util:map-domain 0 1 0 angle (action-step action))))
    (ecase (or (fl.util:href attrs :axis) :z)
      (:x (fl.comp:rotate transform (flm:vec3 step 0 0) :replace-p t))
      (:y (fl.comp:rotate transform (flm:vec3 0 step 0) :replace-p t))
      (:z (fl.comp:rotate transform (flm:vec3 0 0 step) :replace-p t)))))

(defmethod on-action-finish (action (type (eql 'rotate)))
  (when (repeat-p action)
    (replace-action action 'rotate/reverse)))

(defmethod on-action-update (action (type (eql 'rotate/reverse)))
  (let* ((transform (fl.comp:transform (renderer (manager action))))
         (attrs (attrs action))
         (angle (or (fl.util:href attrs :angle) (* pi 2)))
         (step (- angle (fl.util:map-domain 0 1 0 angle (action-step action)))))
    (ecase (or (fl.util:href attrs :axis) :z)
      (:x (fl.comp:rotate transform (flm:vec3 step 0 0) :replace-p t))
      (:y (fl.comp:rotate transform (flm:vec3 0 step 0) :replace-p t))
      (:z (fl.comp:rotate transform (flm:vec3 0 0 step) :replace-p t)))))

(defmethod on-action-finish (action (type (eql 'rotate/reverse)))
  (when (repeat-p action)
    (replace-action action 'rotate)))