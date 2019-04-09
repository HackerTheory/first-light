(in-package :first-light.example)

;;; Textures

(fl:define-texture 1d-gradient
    (:texture-1d fl.textures:clamp-all-edges)
  (:data #((:example-texture "texture-gradient-1d.tiff"))))

(fl:define-texture 2d-wood
    (:texture-2d fl.textures:clamp-all-edges)
  (:data #((:example-texture "wood.tiff"))))

(fl:define-texture 3d
    (:texture-3d fl.textures:clamp-all-edges)
  ;; TODO: Currently, these are the only valid origin and slices values. They
  ;; directly match the default of opengl.
  (:layout `((:origin :left-back-bottom)
             (:shape (:slices :back-to-front))))
  ;; TODO: Maybe I shuld implement pattern specification of mipmaps.
  (:data #(#((:3d "slice_0-mip_0.tiff")
             (:3d "slice_1-mip_0.tiff")
             (:3d "slice_2-mip_0.tiff")
             (:3d "slice_3-mip_0.tiff")
             (:3d "slice_4-mip_0.tiff")
             (:3d "slice_5-mip_0.tiff")
             (:3d "slice_6-mip_0.tiff")
             (:3d "slice_7-mip_0.tiff"))
           #((:3d "slice_0-mip_1.tiff")
             (:3d "slice_1-mip_1.tiff")
             (:3d "slice_2-mip_1.tiff")
             (:3d "slice_3-mip_1.tiff"))
           #((:3d "slice_0-mip_2.tiff")
             (:3d "slice_1-mip_2.tiff"))
           #((:3d "slice_0-mip_3.tiff")))))

(fl:define-texture 1d-array
    (:texture-1d-array fl.textures:clamp-all-edges)
  ;; If there are multiple images in each list, they are mipmaps. Since this is
  ;; a test, each mip_0 image is 8 width x 1 height
  (:data #(#((:1da "redline-mip_0.tiff")
             (:1da "redline-mip_1.tiff")
             (:1da "redline-mip_2.tiff")
             (:1da "redline-mip_3.tiff"))
           #((:1da "greenline-mip_0.tiff")
             (:1da "greenline-mip_1.tiff")
             (:1da "greenline-mip_2.tiff")
             (:1da "greenline-mip_3.tiff"))
           #((:1da "blueline-mip_0.tiff")
             (:1da "blueline-mip_1.tiff")
             (:1da "blueline-mip_2.tiff")
             (:1da "blueline-mip_3.tiff"))
           #((:1da "whiteline-mip_0.tiff")
             (:1da "whiteline-mip_1.tiff")
             (:1da "whiteline-mip_2.tiff")
             (:1da "whiteline-mip_3.tiff")))))

(fl:define-texture 2d-array
    (:texture-2d-array fl.textures:clamp-all-edges)
  ;; Since this is a test, each mip_0 image is 1024x1024 and has 11 mipmaps.
  (:data #(#((:2da "bluefur-mip_0.tiff")
             (:2da "bluefur-mip_1.tiff")
             (:2da "bluefur-mip_2.tiff")
             (:2da "bluefur-mip_3.tiff")
             (:2da "bluefur-mip_4.tiff")
             (:2da "bluefur-mip_5.tiff")
             (:2da "bluefur-mip_6.tiff")
             (:2da "bluefur-mip_7.tiff")
             (:2da "bluefur-mip_8.tiff")
             (:2da "bluefur-mip_9.tiff")
             (:2da "bluefur-mip_10.tiff"))
           #((:2da "bark-mip_0.tiff")
             (:2da "bark-mip_1.tiff")
             (:2da "bark-mip_2.tiff")
             (:2da "bark-mip_3.tiff")
             (:2da "bark-mip_4.tiff")
             (:2da "bark-mip_5.tiff")
             (:2da "bark-mip_6.tiff")
             (:2da "bark-mip_7.tiff")
             (:2da "bark-mip_8.tiff")
             (:2da "bark-mip_9.tiff")
             (:2da "bark-mip_10.tiff"))
           #((:2da "rock-mip_0.tiff")
             (:2da "rock-mip_1.tiff")
             (:2da "rock-mip_2.tiff")
             (:2da "rock-mip_3.tiff")
             (:2da "rock-mip_4.tiff")
             (:2da "rock-mip_5.tiff")
             (:2da "rock-mip_6.tiff")
             (:2da "rock-mip_7.tiff")
             (:2da "rock-mip_8.tiff")
             (:2da "rock-mip_9.tiff")
             (:2da "rock-mip_10.tiff"))
           #((:2da "wiggles-mip_0.tiff")
             (:2da "wiggles-mip_1.tiff")
             (:2da "wiggles-mip_2.tiff")
             (:2da "wiggles-mip_3.tiff")
             (:2da "wiggles-mip_4.tiff")
             (:2da "wiggles-mip_5.tiff")
             (:2da "wiggles-mip_6.tiff")
             (:2da "wiggles-mip_7.tiff")
             (:2da "wiggles-mip_8.tiff")
             (:2da "wiggles-mip_9.tiff")
             (:2da "wiggles-mip_10.tiff")))))

(fl:define-texture cubemap (:texture-cube-map)
  (:data
   ;; TODO: Only :six (individual images) is supported currently.
   #(((:layout :six) ;; :equirectangular, :skybox, etc, etc.
      #((:+x #((:cubemap "right-mip_0.tiff")))
        (:-x #((:cubemap "left-mip_0.tiff")))
        (:+y #((:cubemap "top-mip_0.tiff")))
        (:-y #((:cubemap "bottom-mip_0.tiff")))
        (:+z #((:cubemap "back-mip_0.tiff")))
        (:-z #((:cubemap "front-mip_0.tiff"))))))))

(fl:define-texture cubemaparray (:texture-cube-map-array)
  (:data
   #(((:layout :six)
      #((:+x #((:cubemaparray "right-mip_0.tiff")))
        (:-x #((:cubemaparray "left-mip_0.tiff")))
        (:+y #((:cubemaparray "top-mip_0.tiff")))
        (:-y #((:cubemaparray "bottom-mip_0.tiff")))
        (:+z #((:cubemaparray "back-mip_0.tiff")))
        (:-z #((:cubemaparray "front-mip_0.tiff")))))
     ((:layout :six)
      #((:+x #((:cubemaparray "right-mip_0.tiff")))
        (:-x #((:cubemaparray "left-mip_0.tiff")))
        (:+y #((:cubemaparray "top-mip_0.tiff")))
        (:-y #((:cubemaparray "bottom-mip_0.tiff")))
        (:+z #((:cubemaparray "back-mip_0.tiff")))
        (:-z #((:cubemaparray "front-mip_0.tiff"))))))))

;;; Materials

(fl:define-material 1d-gradient
  (:shader fl.gpu.user:unlit-texture-1d
   :profiles (fl.materials:u-mvp)
   :uniforms
   ((:tex.sampler1 '1d-gradient)
    (:mix-color (m:vec4 1)))))

(fl:define-material 2d-wood
  (:shader fl.gpu.texture:unlit-texture
   :profiles (fl.materials:u-mvp)
   :uniforms
   ((:tex.sampler1 '2d-wood)
    (:mix-color (m:vec4 1)))))

(fl:define-material 3d
  (:shader fl.gpu.user:unlit-texture-3d
   :profiles (fl.materials:u-mvp)
   :uniforms
   ((:tex.sampler1 '3d)
    (:mix-color (m:vec4 1))
    (:uv-z (lambda (context material)
             (declare (ignore material))
             ;; make sin in the range of 0 to 1 for texture coord.
             (/ (1+ (sin (* (fl:total-time context) 1.5))) 2.0))))))

(fl:define-material 1d-array
  (:shader fl.gpu.user:unlit-texture-1d-array
   :profiles (fl.materials:u-mvpt)
   :uniforms
   ((:tex.sampler1 '1d-array)
    (:mix-color (m:vec4 1))
    (:num-layers 4))))

(fl:define-material 2d-array
  (:shader fl.gpu.user:unlit-texture-2d-array
   :profiles (fl.materials:u-mvpt)
   :uniforms
   ((:tex.sampler1 '2d-array)
    (:mix-color (m:vec4 1))
    (:uv-z (lambda (context material)
             (declare (ignore material))
             ;; make sin in the range of 0 to 1 for texture coord.
             (/ (1+ (sin (* (fl:total-time context) 1.5))) 2.0)))
    (:num-layers 4))))

(fl:define-material 2d-sweep-input
  (:shader fl.gpu.user:noise-2d/sweep-input
   :profiles (fl.materials:u-mvp)
   :uniforms
   ;; any old 2d texture here will do since we overwrite it with noise.
   ((:tex.sampler1 '2d-wood)
    (:tex.channel0 (m:vec2))
    (:mix-color (m:vec4 1)))))

(fl:define-material cubemap
  (:shader fl.gpu.user:unlit-texture-cube-map
   :profiles (fl.materials:u-mvp)
   :uniforms
   ((:tex.sampler1 'cubemap)
    (:mix-color (m:vec4 1)))))

(fl:define-material cubemaparray
  (:shader fl.gpu.user:unlit-texture-cube-map-array
   :profiles (fl.materials:u-mvp)
   :uniforms
   ((:tex.sampler1 'cubemaparray)
    (:mix-color (m:vec4 1))
    (:cube-layer (lambda (context material)
                   (declare (ignore material))
                   ;; make sin in the range of 0 to 1 for texture coord.
                   (/ (1+ (sin (* (fl:total-time context) 1.5))) 2.0)))
    (:num-layers 2))))

;;; Components

(fl:define-component shader-sweep ()
  ((renderer :default nil)
   (material :defualt nil)
   (material-retrieved-p :default nil)
   (mouse-in-window-p :default nil)
   (channel0 :default (m:vec2))))

(defmethod fl:on-component-initialize ((self shader-sweep))
  (setf (renderer self) (fl:actor-component-by-type (fl:actor self) 'render)))

(defmethod fl:on-component-update ((self shader-sweep))
  (with-accessors ((renderer renderer) (material-copied-p material-copied-p)
                   (material material)
                   (material-retrieved-p material-retrieved-p)
                   (channel0 channel0) (max-x max-x) (max-y max-y))
      self
    (unless material-retrieved-p
      (setf material (fl.comp:material renderer)
            material-retrieved-p t))
    (au:mvlet* ((context (fl:context self))
                (x y (fl.input:get-mouse-position (fl:input-data context))))
      (when (null x) (setf x (/ (fl:option context :window-width) 2.0)))
      (when (null y) (setf y (/ (fl:option context :window-height) 2.0)))
      (m:with-vec2 ((c channel0))
        ;; crappy, but good enough.
        (setf c.x (float (/ x (fl:option context :window-width)) 1f0)
              c.y (float (/ y (fl:option context :window-height)) 1f0)))
      ;; get a reference to the material itself (TODO: use MOP stuff to get
      ;; this right so I don't always have to get it here)
      (setf (fl:mat-uniform-ref material :tex.channel0) channel0))))

;;; Prefabs

(fl:define-prefab "texture" (:library examples)
  (("camera" :copy "/cameras/perspective")
   (fl.comp:camera (:policy :new-args) :zoom 6))
  (("1d-texture" :copy "/mesh")
   (fl.comp:transform (:policy :new-type) :translate (m:vec3 -4 3 0))
   (fl.comp:render (:policy :new-type) :material '1d-gradient))
  (("2d-texture" :copy "/mesh")
   (fl.comp:transform (:policy :new-type) :translate (m:vec3 -2 3 0))
   (fl.comp:render (:policy :new-type) :material '2d-wood))
  (("3d-texture" :copy "/mesh")
   (fl.comp:transform (:policy :new-type) :translate (m:vec3 0 3 0))
   (fl.comp:render (:policy :new-type) :material '3d))
  (("1d-array-texture" :copy "/mesh")
   (fl.comp:transform (:policy :new-type) :translate (m:vec3 2 3 0))
   (fl.comp:render (:policy :new-type) :material '1d-array))
  (("2d-array-texture" :copy "/mesh")
   (fl.comp:transform (:policy :new-type) :translate (m:vec3 4 3 0))
   (fl.comp:render (:policy :new-type)
                   :material '2d-array))
  (("swept-input" :copy "/mesh")
   (fl.comp:transform (:policy :new-type) :translate (m:vec3 -4 1 0))
   (fl.comp:render (:policy :new-type) :material '2d-sweep-input)
   (shader-sweep))
  (("cube-map" :copy "/mesh")
   (fl.comp:transform (:policy :new-type)
                      :translate (m:vec3 0 -1 0)
                      :rotate (m:vec3 0.5))
   (fl.comp:mesh (:policy :new-type) :location '((:core :mesh) "cube.glb"))
   (fl.comp:render (:policy :new-type) :material 'cubemap))
  (("cube-map-array" :copy "/mesh")
   (fl.comp:transform (:policy :new-type)
                      :translate (m:vec3 3 -1 0)
                      :rotate/inc (m:vec3 0.5))
   (fl.comp:mesh (:policy :new-type) :location '((:core :mesh) "cube.glb"))
   (fl.comp:render (:policy :new-type)
                   :material 'cubemaparray)))