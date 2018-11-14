(in-package :%fl)

;; The textures-table is a data store of everything in the .tex extension.  This
;; includes any texture-profiles, and defined textures (as texture-descriptors.
;; It is kept in a slot in core-state.
(defclass textures-table ()
  ((%profiles :reader profiles
              :initarg :profiles
              :initform (au:dict #'eq))
   (%texture-descriptors :reader texture-descriptors
                         :initarg :texture-descriptors
                         :initform (au:dict #'eq))))

(defun %make-textures-table (&rest init-args)
  (apply #'make-instance 'textures-table init-args))

(defun %add-texture-profile (profile core-state)
  (setf (au:href (profiles (textures core-state)) (name profile))
        profile))

(defun %add-texture-descriptor (texdesc core-state)
  (setf (au:href (texture-descriptors (textures core-state)) (name texdesc))
        texdesc))

(defclass texture-profile ()
  ((%name :reader name
          :initarg :name)
   (%attributes :reader attributes
                :initarg :attributes
                :initform (au:dict #'eq))))

;; TODO candidate for public API
(defun make-texture-profile (&rest init-args)
  (apply #'make-instance 'texture-profile init-args))

(defclass texture-descriptor ()
  ((%name :reader name
          :initarg :name)
   (%texture-type :reader texture-type
                  :initarg :texture-type)
   (%profile-overlay-names :reader profile-overlay-names
                           :initarg :profile-overlay-names)
   ;; Attribute specified in the define-texture form
   (%attributes :reader attributes
                :initarg :attributes
                :initform (au:dict #'eq))
   ;; Up to date attributes once the profiles have been applied.
   (%applied-attributes :reader applied-attributes
                        :initarg :applied-attributes
                        :initform (au:dict #'eq))))

;; TODO candidate for public API
(defun make-texture-descriptor (&rest init-args)
  (apply #'make-instance 'texture-descriptor init-args))

(defclass texture ()
  (;; The descriptor from when we derived this texture.
   (%texdesc :reader texdesc
             :initarg :texdesc)

   ;; The allocated opengl texture id.
   (%texid :reader texid
           :initarg :texid)))

(defun set-opengl-texture-parameters (texture)
  (with-accessors ((texture-type texture-type)
                   (applied-attributes applied-attributes))
      (texdesc texture)
    (let ((texture-parameters
            '(:depth-stencil-texture-mode :texture-base-level
              :texture-border-color :texture-compare-func
              :texture-compare-mode :texture-lod-bias
              :texture-min-filter :texture-mag-filter
              :texture-min-lod :texture-max-lod
              :texture-max-level :texture-swizzle-r
              :texture-swizzle-g :texture-swizzle-b
              :texture-swizzle-a :texture-swizzle-rgba
              :texture-wrap-s :texture-wrap-t :texture-wrap-r)))
      (loop :for putative-parameter :in texture-parameters
            :do (au:when-found (value (au:href applied-attributes
                                               putative-parameter))
                  (gl:tex-parameter texture-type putative-parameter value))))))

(defun get-applied-attribute (texture attribute-name)
  (au:href (applied-attributes (texdesc texture)) attribute-name))

(defun (setf get-applied-attribute) (newval texture attribute-name)
  (setf (au:href (applied-attributes (texdesc texture)) attribute-name) newval))

;; TODO: These are cut into individual functions for their context. Maybe later
;; I'll see about condensing them to be more concise.

(defgeneric load-texture-data (texture-type texture context)
  (:documentation "Load actual data described in the TEXTURE's texdesc of
TEXTURE-TYPE into the texture memory."))

(defun read-mipmap-images (context data use-mipmaps-p)
  "Read the images described in the mipmap location array DATA into main
memory. If USE-MIPMAPS-P is true, then load all of the mipmaps, otherwise only
load the base image, which is the first one in the array. CONTEXT is the
core-state context slot value. Return a vector of image structure from the
function READ-IMAGE."
  (if use-mipmaps-p
      (map 'vector (lambda (loc) (read-image context loc)) data)
      (vector (read-image context (aref data 0)))))

(defun free-mipmap-images (images)
  "Free all main memory associated with the vector of image objects in IMAGES."
  (loop :for image :across images
        :do (free-storage image)))

(defun validate-mipmap-images (images texture
                               expected-mipmaps expected-resolutions)
  "Given the settings in the TEXTURE, validate the real image objects in the
IMAGES vector to see if we have the expected number and resolution of mipmaps."
  (declare (ignorable expected-resolutions))

  (let* ((use-mipmaps-p (get-applied-attribute texture :use-mipmaps))
         (texture-max-level
           (get-applied-attribute texture :texture-max-level))
         (texture-base-level
           (get-applied-attribute texture :texture-base-level))
         (max-mipmaps (- texture-max-level texture-base-level))
         (num-mipmaps (length images))
         (texture-name (name (texdesc texture))))

    ;; We need at least one base image.
    ;; TODO: When dealing with procedurally generated textures, this needs
    ;; to be evolved.
    (unless (> num-mipmaps 0)
      (error "Texture ~A specifies no images! Please specify an image!"
             texture-name))

    (when use-mipmaps-p
      (cond
        ;; We have a SINGLE base mipmap (and we're generating them all).
        ((= num-mipmaps 1)
         ;; TODO: Check resolution.
         nil)
        ;; We have the exact number of expected mipmaps.
        ((and (= num-mipmaps expected-mipmaps)
              (<= num-mipmaps max-mipmaps))
         ;; TODO: Check resolutions.
         nil)
        ;; We have the exact number of mipmaps required that fills the
        ;; entire range expected by this texture.
        ((= num-mipmaps max-mipmaps)
         ;; TODO: Check resolutions
         nil)
        ;; Otherwise, something went wrong.
        ;; TODO: Should do a better error message which diagnoses what's wrong.
        (t
         (error "Texture ~A mipmap levels are incorrect:~%~2Ttexture-base-level = ~A~%~2Ttexture-max-level = ~A~%~2Tnumber of mipmaps specified in texture = ~A~%~2Texpected number of mipmaps = ~A~%Probably too many or to few specified mipmap images."
                texture-name
                texture-base-level
                texture-max-level
                num-mipmaps
                expected-mipmaps))))
    ))

(defun potentially-degrade-texture-min-filter (texture)
  "If the TEXTURE is not using mipmaps, fix the :texture-min-filter attribute
on the texture to something appropriate if it is currently set to using
mipmap related interpolation."
  (let ((use-mipmaps-p (get-applied-attribute texture :use-mipmaps))
        (texture-name (name (texdesc texture))))
    (symbol-macrolet ((current-tex-min-filter
                        (get-applied-attribute texture :texture-min-filter)))

      (unless use-mipmaps-p
        (case current-tex-min-filter
          ((:nearest-mipmap-nearest :nearest-mipmap-linear)
           (warn "Down converting nearest texture min mipmap filter due to disabled mipmaps. Please specify an override :texture-min-filter for texture ~A"
                 texture-name)
           (setf current-tex-min-filter :nearest))
          ((:linear-mipmap-nearest :linear-mipmap-linear)
           (warn "Down converting linear texture min mipmap filter due to disabled mipmaps. Please specify an override :texture-min-filter for texture ~A"
                 texture-name)
           (setf current-tex-min-filter :linear)))))))

(defun potentially-autogenerate-mipmaps (texture-type texture)
  "If, for this TEXTURE, we are using mipmaps, and only supplied a single base
image, then we use GL:GENERASTE-MIPMAP to auto create all of the mipmaps
in the GPU memory."
  (let* ((use-mipmaps-p (get-applied-attribute texture :use-mipmaps))
         (texture-max-level
           (get-applied-attribute texture :texture-max-level))
         (texture-base-level
           (get-applied-attribute texture :texture-base-level))
         (max-mipmaps (- texture-max-level texture-base-level))
         (data (get-applied-attribute texture :data))
         (num-mipmaps (length data)))

    (when (and use-mipmaps-p
               (= num-mipmaps 1) ;; We didn't supply any but the base image.
               (> max-mipmaps 1)) ;; And we're expecting some to exist.
      (gl:generate-mipmap texture-type))))


(defmethod load-texture-data ((texture-type (eql :texture-1d)) texture context)
  ;; TODO: This assumes no use of the general-data-descriptor or procedurally
  ;; generated content.

  (let* ((use-mipmaps-p (get-applied-attribute texture :use-mipmaps))
         (immutable-p (get-applied-attribute texture :immutable))
         (texture-max-level
           (get-applied-attribute texture :texture-max-level))
         (texture-base-level
           (get-applied-attribute texture :texture-base-level))
         (max-mipmaps (- texture-max-level texture-base-level))
         (data (get-applied-attribute texture :data)))

    ;; load all of the images we may require.
    (let ((images (read-mipmap-images context data use-mipmaps-p)))

      ;; Check to ensure they all fit into texture memory.
      ;;
      ;; TODO: Refactor out of each method into validate-mipmap-images and
      ;; generalize.
      (loop :for image :across images
            :for location :across data
            :do (when (> (max (height image) (width image))
                         (gl:get-integer :max-texture-size))
                  (error "Image ~A for 1D texture ~A is to big to be loaded onto this card. Max resolution is ~A in either dimension."
                         location
                         (name (texdesc texture))
                         (gl:get-integer :max-texture-size))))

      ;; Figure out the ideal mipmap count from the base resolution.
      (multiple-value-bind (expected-mipmaps expected-resolutions)
          (compute-mipmap-levels (width (aref images 0))
                                 (height (aref images 0)))

        (validate-mipmap-images images texture
                                expected-mipmaps expected-resolutions)

        (potentially-degrade-texture-min-filter texture)

        ;; Allocate immutable storage if required.
        (when immutable-p
          (let ((num-mipmaps-to-generate
                  (if use-mipmaps-p (min expected-mipmaps max-mipmaps) 1)))
            (%gl:tex-storage-1d texture-type num-mipmaps-to-generate
                                (internal-format (aref images 0))
                                (width (aref images 0)))))

        ;; Upload all of the mipmap images into the texture ram.
        ;; TODO: Make this higher order.
        (loop :for idx :below (if use-mipmaps-p (length images) 1)
              :for level = (+ texture-base-level idx)
              :for image = (aref images idx)
              :do (with-slots (%width %height %internal-format %pixel-format
                               %pixel-type %data)
                      image
                    (if immutable-p
                        (gl:tex-sub-image-1d texture-type level 0
                                             %width
                                             %pixel-format %pixel-type %data)
                        (gl:tex-image-1d texture-type level %internal-format
                                         %width 0
                                         %pixel-format %pixel-type %data))))

        ;; And clean up main memory.
        ;; TODO: For procedural textures, this needs evolution.
        (free-mipmap-images images)

        ;; Determine if opengl should generate the mipmaps.
        (potentially-autogenerate-mipmaps texture-type texture)))))

(defmethod load-texture-data ((texture-type (eql :texture-2d)) texture context)
  ;; TODO: This assumes no use of the general-data-descriptor or procedurally
  ;; generated content.

  (let* ((use-mipmaps-p (get-applied-attribute texture :use-mipmaps))
         (immutable-p (get-applied-attribute texture :immutable))
         (texture-max-level
           (get-applied-attribute texture :texture-max-level))
         (texture-base-level
           (get-applied-attribute texture :texture-base-level))
         (max-mipmaps (- texture-max-level texture-base-level))
         (data (get-applied-attribute texture :data)))

    ;; load all of the images we may require.
    (let ((images (read-mipmap-images context data use-mipmaps-p)))

      ;; Check to ensure they all fit into texture memory.
      ;;
      ;; TODO: Refactor out of each method into validate-mipmap-images and
      ;; generalize.
      (loop :for image :across images
            :for location :across data
            :do (when (> (max (height image) (width image))
                         (gl:get-integer :max-texture-size))
                  (error "Image ~A for texture ~A is to big to be loaded onto this card. Max resolution is ~A in either dimension."
                         location
                         (name (texdesc texture))
                         (gl:get-integer :max-texture-size))))

      ;; Figure out the ideal mipmap count from the base resolution.
      (multiple-value-bind (expected-mipmaps expected-resolutions)
          (compute-mipmap-levels (width (aref images 0))
                                 (height (aref images 0)))

        (validate-mipmap-images images texture
                                expected-mipmaps expected-resolutions)

        (potentially-degrade-texture-min-filter texture)

        ;; Allocate immutable storage if required.
        (when immutable-p
          (let ((num-mipmaps-to-generate
                  (if use-mipmaps-p (min expected-mipmaps max-mipmaps) 1)))
            (%gl:tex-storage-2d texture-type num-mipmaps-to-generate
                                (internal-format (aref images 0))
                                (width (aref images 0))
                                (height (aref images 0)))))

        ;; Upload all of the mipmap images into the texture ram.
        ;; TODO: Make this higher order.
        (loop :for idx :below (if use-mipmaps-p (length images) 1)
              :for level = (+ texture-base-level idx)
              :for image = (aref images idx)
              :do (with-slots (%width %height %internal-format %pixel-format
                               %pixel-type %data)
                      image
                    (if immutable-p
                        (gl:tex-sub-image-2d texture-type level 0 0
                                             %width %height
                                             %pixel-format %pixel-type %data)
                        (gl:tex-image-2d texture-type level %internal-format
                                         %width %height 0
                                         %pixel-format %pixel-type %data))))

        ;; And clean up main memory.
        ;; TODO: For procedural textures, this needs evolution.
        (free-mipmap-images images)

        ;; Determine if opengl should generate the mipmaps.
        (potentially-autogenerate-mipmaps texture-type texture)))))


(defmethod load-texture-data ((texture-type (eql :texture-3d)) texture context)
  ;; Determine if loading :images or :volume
  (error "load-texture-data: :texture-3d implement me")

  ;; Validating a 3d texture.
  ;; 1. Ensure that all images/mipmaps are of identical and valid dimensions.
  ;; 2. Ensure that it fits into the current limits on the card

  (let* ((use-mipmaps-p (get-applied-attribute texture :use-mipmaps))
         (immutable-p (get-applied-attribute texture :immutable))
         (texture-max-level
           (get-applied-attribute texture :texture-max-level))
         (texture-base-level
           (get-applied-attribute texture :texture-base-level))
         (max-mipmaps (- texture-max-level texture-base-level))
         (data (get-applied-attribute texture :data))
         (num-mipmaps (length data)))

    nil))

(defmethod load-texture-data ((texture-type (eql :texture-cube-map)) texture context)
  (error "load-texture-data: :texture-cube-map implement me")
  nil)

(defmethod load-texture-data ((texture-type (eql :texture-rectangle)) texture context)
  (error "load-texture-data: :texture-rectangle implement me")
  ;; Determine if loading :image or :planar
  nil)

(defmethod load-texture-data ((texture-type (eql :texture-1d-array)) texture context)
  (error "load-texture-data: :texture-1d-array implement me")
  nil)

(defmethod load-texture-data ((texture-type (eql :texture-2d-array)) texture context)
  (error "load-texture-data: :texture-2d-array implement me")
  nil)

(defmethod load-texture-data ((texture-type (eql :texture-cube-map-array)) texture context)
  (error "load-texture-data: :texture-cube-map-array implement me")
  nil)

(defun load-texture (context texture-name)
  (let ((texdesc (au:href (texture-descriptors (textures (core-state context))) texture-name)))
    (unless texdesc
      (error "Cannot load texture with unknown name: ~A" texture-name))
    (let* ((id (gl:gen-texture))
           (texture (make-instance 'texture :texdesc texdesc :texid id)))
      (gl:bind-texture (texture-type texdesc) id)
      (set-opengl-texture-parameters texture)
      (load-texture-data (texture-type texdesc) texture context)
      texture)))

(defun parse-texture-profile (name body-form)
  (let ((texprof (gensym "TEXTURE-PROFILE")))
    `(let* ((,texprof (make-texture-profile :name ',name)))
       (setf ,@(loop :for (attribute value) :in body-form :appending
                     `((au:href (attributes ,texprof) ,attribute) ,value)))
       ,texprof)))

(defmacro define-texture-profile (name &body body)
  "Define a set of attribute defaults that can be applied while defining a texture."
  (let ((texprof (gensym "TEXPROF")))
    `(let* ((,texprof ,(parse-texture-profile name body)))
       (declare (special %temp-texture-profiles))
       (setf (au:href %temp-texture-profiles (name ,texprof)) ,texprof))))

(defmacro define-texture (name (textype &rest profile-overlay-names) &body body)
  (let ((texdesc (gensym "TEXDESC")))
    `(let ((,texdesc (make-texture-descriptor :name ',name
                                              :texture-type ',textype
                                              :profile-overlay-names ',profile-overlay-names)))
       (declare (special %temp-texture-descriptors))
       ;; Record the parameters we'll overlay on the profile at use time.
       (setf ,@(loop :for (key value) :in body
                     :append `((au:href (attributes ,texdesc) ,key) ,value))
             (au:href %temp-texture-descriptors (name ,texdesc)) ,texdesc)
       (export ',name))))

(defmethod extension-file-type ((extension-type (eql :textures)))
  "tex")

(defmethod prepare-extension ((extension-type (eql :textures)) core-state)
  (let ((%temp-texture-descriptors (au:dict #'eq))
        (%temp-texture-profiles (au:dict #'eq)))
    (declare (special %temp-texture-descriptors %temp-texture-profiles))
    (flet ((%prepare ()
             (map-extensions extension-type (data-path core-state))
             (values %temp-texture-profiles %temp-texture-descriptors)))
      (multiple-value-bind (profiles texdescs) (%prepare)
        ;; The order doesn't matter. we can type check the texture-descriptors
        ;; after reading _all_ the available textures extensions.
        ;; Process all defined profiles.
        (au:do-hash-values (v profiles)
          (%add-texture-profile v core-state))
        ;; Process all texture-descriptors
        (au:do-hash-values (v texdescs)
          (%add-texture-descriptor v core-state))))))

(defun resolve-all-textures (core-state)
  "This is called after all the textures are loaded in the extensions.
Ensure that these aspects of texture profiles and desdcriptors are ok:
1. The FL.TEXTURES:DEFAULT-PROFILE exists.
2. Each texture-descriptor has an updated applied-profile set of attributes.
3. All currently known about texture descriptors have valid profile references.
4. All images specified by paths actually exist at that path.
5. The texture type is valid."
  (symbol-macrolet ((profiles (profiles (textures core-state)))
                    (default-profile-name (au:ensure-symbol 'default-profile 'fl.textures)))
    ;; 1. Check for fl.textures:default-profile
    (unless (au:href profiles default-profile-name)
      (error "Default-profile for texture descriptors is not defined."))
    ;; 2. For each texture-descriptor, apply all the profiles in order.
    ;; 3. Check that the specified profiles are valid.
    (au:do-hash-values (v (texture-descriptors (textures core-state)))
      (let* ((profile-overlays
               ;; First, gather the specified profile-overlays
               (loop :for profile-overlay-name :in (profile-overlay-names v)
                     :collect
                     (au:if-found (concrete-profile (au:href profiles profile-overlay-name))
                                  concrete-profile
                                  (error "Texture profile ~A does not exist."
                                         profile-overlay-name))))
             (profile-overlays
               ;; Then, if we don't see a profile-default in there, we
               ;; put it first automatically.
               (if (member default-profile-name (profile-overlay-names v))
                   profile-overlays
                   (list* (au:href profiles default-profile-name) profile-overlays))))
        ;; Now, overlay them left to right into the applied-attributes table
        ;; in texdesc.
        (dolist (profile-overlay profile-overlays)
          (maphash
           (lambda (key val)
             (setf (au:href (applied-attributes v) key) val))
           (attributes profile-overlay)))
        ;; And finally fold in the texdesc attributes last
        (maphash
         (lambda (key val)
           (setf (au:href (applied-attributes v) key) val))
         (attributes v)))
      (texture-descriptors (textures core-state)))

    ;; TODO: 4
    ;; TODO: 5

    nil))

;; public API
(defun general-data-format-descriptor (&key width height depth internal-format pixel-format
                                         pixel-type data)
  "Produce a descriptor for generalized volumetric data to be loaded into a :texture-3d type
texture. If :data has the value :empty, allocate the memory of the size and types specified on the
GPU."
  ;; TODO: Implement me!
  (declare (ignore width height depth internal-format pixel-format pixel-type data))
  #())

;; Interim use of the RCACHE API.

(defmethod rcache-layout ((entry-type (eql :texture)))
  '(equalp))

(defmethod rcache-construct ((entry-type (eql :texture)) (core-state core-state) &rest keys)
  (destructuring-bind (texture-location) keys
    (load-texture (context core-state) texture-location)))

(defmethod rcache-dispose ((entry-type (eql :texture)) (core-state core-state) texture)
  (gl:delete-texture (texid texture)))


;; Utility functions for texturing, maybe move elsewhere.

(defun round-down (x)
  (ceiling (- x 1/2)))

(defun round-up (x)
  (floor (+ x 1/2)))

(defun compute-mipmap-levels (width height &optional (depth 1))
  "Compute how many mipmaps and what their resolutions must be given a
WIDTH, HEIGHT, and DEPTH (which defaults to 1) size of a texture. We
follow Opengl's formula in dealing with odd sizes (being rounded down).
Return a values of:
  the number of mipmap levels
  the list of resolutions from biggest to smallest each mip map must have."
  (let ((num-levels (+ 1 (floor (log (max width height depth) 2))))
        (resolutions nil))
    (push (list width height depth) resolutions)
    (loop
      :with new-width = width
      :with new-height = height
      :with new-depth = depth
      :for level :below (1- num-levels) :do
        (setf new-width (max (round-down (/ new-width 2)) 1)
              new-height (max (round-down (/ new-height 2)) 1)
              new-depth (max (round-down (/ new-depth 2)) 1))
        (push (list new-width new-height new-depth) resolutions))
    (values num-levels (nreverse resolutions))))
