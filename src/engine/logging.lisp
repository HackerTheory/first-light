(in-package :fl.core)

(slog:define-message :info :engine.start
  "Started ~a.")

(slog:define-message :info :engine.quit
  "Stopped ~a.")

(slog:define-message :trace :extension.load
  "Loaded extension (~(~a~)): ~a.")

(slog:define-message :debug :display.init
  "Display ~dx~d @ ~dHz created.")

(slog:define-message :debug :display.stop
  "Display ~dx~d @ ~dHz destroyed.")

(slog:define-message :debug :input.key.down
  "Key pressed: ~a.")

(slog:define-message :debug :input.key.up
  "Key released: ~a.")

(slog:define-message :debug :input.scroll.up
  "Mouse wheel scrolled up.")

(slog:define-message :debug :input.scroll.down
  "Mouse wheel scrolled down.")

(slog:define-message :trace :flow.enter
  "Entering flow: (~a ~a ~a).")

(slog:define-message :trace :flow.state.process
  "Processing flow-state: ~a, exiting: ~a.")

(slog:define-message :trace :flow.call.selector
  "Calling selector function.")

(slog:define-message :trace :flow.call.action.hash
  "Calling action function (hash).")

(slog:define-message :trace :flow.call.action.instance
  "Calling action function (instance).")

(slog:define-message :trace :flow.call.transition
  "Calling transition function.")

(slog:define-message :trace :flow.exit
  "Exiting flow: (~a ~a ~a).")

(slog:define-message :debug :shader.function.compiled
  "Compiled shader function: ~a")

(slog:define-message :trace :component.mesh.cache.used
  "Used a cached copy of mesh: ~a")

(slog:define-message :trace :component.mesh.cache.created
  "Creating a new cached mesh for: ~a")