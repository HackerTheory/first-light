(asdf:defsystem #:first-light
  :description "An experimental game engine."
  :author ("Michael Fiano <mail@michaelfiano.com>"
           "Peter Keller <psilord@cs.wisc.edu>"
           "Bart Botta <00003b at gmail.com>"
           "Elijah Malaby <djeis>")
  :maintainer ("Michael Fiano <mail@michaelfiano.com>"
               "Peter Keller <psilord@cs.wisc.edu>")
  :license "MIT"
  :homepage "https://github.com/hackertheory/first-light"
  :bug-tracker "https://github.com/hackertheory/first-light/issues"
  :source-control (:git "git@github.com:hackertheory/first-light.git")
  :encoding :utf-8
  :long-description #.(uiop:read-file-string
                       (uiop/pathname:subpathname *load-pathname* "README.md"))
  :depends-on (#:closer-mop
               #:defpackage-plus
               #:cl-ppcre
               #:cl-graph
               #:cl-opengl
               #:sdl2
               #:verbose
               #:golden-utils
               #:game-math
               #:first-light.metadata
               #:first-light.data-structures
               #:first-light.binary-formats
               #:first-light.host
               #:first-light.image-types
               #:first-light.geometry
               #:first-light.input
               #:first-light.gpu
               #:first-light.gpu-lib)
  :pathname "core"
  :serial t
  :components
  ((:module "packages"
    :components
    ((:file "internal")
     (:file "materials")
     (:file "textures")
     (:file "annotations")
     (:file "components")
     (:file "actions")
     (:file "prefab")
     (:file "api")))
   (:module "mop"
    :components
    ((:file "component")))
   (:module "util"
    :components
    ((:file "common")
     (:file "deploy")
     (:file "live-coding")
     (:file "uuid")))
   (:module "textures"
    :components
    ((:file "texture")
     (:file "common")
     (:file "1d")
     (:file "2d")
     (:file "3d")
     (:file "1d-array")
     (:file "2d-array")
     (:file "cube-map")
     (:file "cube-map-array")
     (:file "rectangle")
     (:file "buffer")))
   (:file "resource")
   (:file "context")
   (:file "options")
   (:file "logging")
   (:file "graph")
   (:file "flow")
   (:file "shared-storage")
   (:file "attributes")
   (:file "actor")
   (:file "component")
   (:file "annotations")
   (:file "frame")
   (:file "display")
   (:file "materials")
   (:file "shaders")
   (:file "colliders")
   (:file "action-manager")
   (:file "core-state")
   (:file "engine")
   (:module "components"
    :components
    ((:file "transform")
     (:file "action-list")
     (:file "camera")
     (:file "camera-following")
     (:file "camera-tracking")
     (:file "mesh")
     (:file "render")
     (:file "sprite")
     (:file "colliders")))
   (:module "prefab"
    :components
    ((:file "checks")
     (:file "prefab")))
   (:module "actions"
    :components
    ((:file "fade")
     (:file "rotate")
     (:file "sprite-animate")))
   (:module "definitions"
    :components
    ((:file "graphs")
     (:file "flows")
     (:file "texture-profiles")
     (:file "textures")
     (:file "material-profiles")
     (:file "materials")))))
