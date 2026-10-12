;; 1. Carica il tema di base che preferisci  -*- lexical-binding: t; -*-
(mapc #'disable-theme custom-enabled-themes)

(load-theme 'tsdh-light t)

;; 2. Sovrascrivi o personalizza le "Faces" per creare la tua combinazione unica
(custom-theme-set-faces
 'tsdh-light  ; Nome del tema base a cui applicare le modifiche

 ;(load-theme 'wombat t)
 
'(font-lock-type-face ((t (:foreground "#c18401" :underline t :slant italic :weight bold))))
					;'(font-lock-keyword-face ((t
					;(:foreground "#a71d5d" :weight bold))))
;; Numeri di riga standard grigio tenue
 '(line-number ((t (:foreground "#a0a1a7" :weight normal))))
'(line-number-current-line ((t (:foreground "#383a42" :background "#e5e5e6"
					    :slant italic :weight bold))))

;; Per la selezione nativa di Emacs
 '(vertico-current ((t (:background "darkseagreen2" :slant italic :weight bold)))))

;:foreground "#7f9f7f"
(provide 'custom-theme-ONE)
