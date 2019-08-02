(in-package #:virality.examples)

;;; Prefabs

(v:define-prefab "geometric-volumes" (:library examples)
  (("camera" :copy "/cameras/perspective"))
  (("plane" :copy "/mesh")
   (comp:transform :rotate/inc (q:orient :local (v3:one) pi)
                   :scale 6))
  (("cube" :copy "/mesh")
   (comp:transform :translate (v3:vec 0 30 0)
                   :rotate/inc (q:orient :local (v3:one) pi)
                   :scale 6)
   (comp:static-mesh :location '((:core :mesh) "cube.glb")))
  (("sphere" :copy "/mesh")
   (comp:transform :translate (v3:vec 0 -30 0)
                   :rotate/inc (q:orient :local (v3:one) pi)
                   :scale 6)
   (comp:static-mesh :location '((:core :mesh) "sphere.glb")))
  (("torus" :copy "/mesh")
   (comp:transform :translate (v3:vec 30 0 0)
                   :rotate/inc (q:orient :local (v3:one) pi)
                   :scale 6)
   (comp:static-mesh :location '((:core :mesh) "torus.glb")))
  (("cone" :copy "/mesh")
   (comp:transform :translate (v3:vec -30 0 0)
                   :rotate/inc (q:orient :local (v3:one) pi)
                   :scale 6)
   (comp:static-mesh :location '((:core :mesh) "cone.glb"))
   (comp:render :material 'contrib.mat:unlit-texture-decal-bright)))

;;; Prefab descriptors

(v:define-prefab-descriptor geometric-volumes ()
  ("geometric-volumes" examples))
