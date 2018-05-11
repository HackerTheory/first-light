(in-package :fl.core)

(defmethod extension-file-type ((extension-type (eql 'shader-stages)))
  "shd")

(defmethod prepare-extension ((extension-type (eql 'shader-stages)) owner path)
  (shadow:initialize-shaders)
  (load-extensions extension-type path))

(defmethod extension-file-type ((extension-type (eql 'shader-programs)))
  "prog")

(defmethod prepare-extension ((extension-type (eql 'shader-programs)) owner path)
  (load-extensions extension-type path))

(defun shaders-modified-hook (programs-list)
  (sdl2:in-main-thread ()
    (shadow:update-shader-programs programs-list)))

(defun prepare-shader-programs (core-state)
  (setf (shaders core-state) (shadow:build-shader-dictionary))
  (shadow:set-modify-hook #'shaders-modified-hook))