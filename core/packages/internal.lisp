(in-package :defpackage+-user-1)

(defpackage+ #:%first-light
  (:nicknames #:%fl)
  (:local-nicknames (#:m #:game-math))
  (:use #:cl)
  (:export
   #:*core-debug*
   #:active-camera
   #:actor
   #:actor-component-by-type
   #:actor-components-by-type
   #:alpha
   #:attach-component
   #:attach-multiple-components
   #:cameras
   #:component
   #:compute-component-initargs
   #:context
   #:copy-material
   #:core
   #:define-annotation
   #:define-component
   #:define-graph
   #:define-material
   #:define-material-profile
   #:define-options
   #:define-resources
   #:define-texture
   #:define-texture-profile
   #:delta
   #:deploy-binary
   #:deregister-collider
   #:destroy
   #:detach-component
   #:find-actors-by-id
   #:find-by-uuid
   #:find-components-by-id
   #:find-resource
   #:frame-count
   #:frame-manager
   #:frame-time
   #:general-data-format-descriptor
   #:get-computed-component-precedence-list
   #:id
   #:input-data
   #:instances
   #:lookup-material
   #:make-actor
   #:make-component
   #:make-scene-tree
   #:mat-uniform-ref
   #:on-component-attach
   #:on-component-destroy
   #:on-component-detach
   #:on-component-initialize
   #:on-component-physics-update
   #:on-component-render
   #:on-component-update
   #:on-collision-enter
   #:on-collision-continue
   #:on-collision-exit
   #:option
   #:prefab-node
   #:print-all-resources
   #:project-data
   #:register-collider
   #:scene-tree
   #:shader
   #:shared-storage
   #:spawn-actor
   #:ss-href
   #:start-engine
   #:state
   #:stop-engine
   #:total-time
   #:using-material
   #:with-shared-storage))
