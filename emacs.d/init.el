;;CONFIGURAZIONE DI EMACS
;;(setq-default mode-line-format (default-value 'mode-line-format))
;;(setq use-package-always-defer t)

(require 'package)
;; Aggiunge MELPA come archivio di pacchetti
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;per evitare di avere ogni volta un buffer dired nuovo ad ogni directory,alla pressone del tasto invio posso farlo nella stessa finestra
;;gli metto uno nuovo che sostituisce il precedente
(use-package nerd-icons-dired
  :ensure t
  :hook (dired-mode . nerd-icons-dired-mode))
(use-package dired-single
  :load-path "~/.emacs.d/lisp"
  :bind (:map dired-mode-map
              ("RET" . dired-single-buffer)
              ("^"   . dired-single-up-directory)))

;;aggiunta di funzionalità a dired/ dired-mode
;(setq dired-mouse-drag-files t) ;;drag dentro a EMACS
;(setq mouse-drag-and-drop-region t)  ;;drag and drop dentro a dired
;(setq mouse-drag-and-drop-region-cross-program t) ;;mouse-drag-and-drop-region-cross-program

;;DIRED SIDEBAR MODIFICHE:lazy loaded per evitare sia caricata quando non serve
(use-package dired-sidebar
  :ensure t
  :commands (dired-sidebar-show-sidebar)
  :hook (c-mode-common . dired-sidebar-show-sidebar))

;; Chiudi sidebar quando il buffer attivo NON è cc-mode
;; (add-hook 'window-selection-change-functions
;;           (lambda (_win)
;;             (with-current-buffer (window-buffer)
;;               (unless (derived-mode-p 'c-mode-common)
;;                 (dired-sidebar-hide-sidebar)))))



;;file recenti attivati
(recentf-mode 1)

;;projectile-mode per gestire progetto
;(use-package projectile
 ; :init (projectile-mode 1)
  ;:custom (projectile-project-search-path '("~/progetti/")))

;;(use-package eldoc
;; :disabled t)

;;pdf.tools
(use-package pdf-tools
  :ensure t
  :defer t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install))

;;vterm
(use-package vterm
  :ensure t
  :defer t
  :commands vterm)

;;Flyspell
(use-package flyspell
  :disabled t
  :ensure t
  ;;:defer t
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))

;;matlab-mode e cuda-mode supporto
(use-package matlab-mode
  :ensure t
  :defer t
  :mode ("\\.m\\'" . matlab-mode))

(use-package cuda-mode
  :ensure t
  :defer t
  :mode ("\\.cu\\'" "\\.cuh\\'"))

  ;;per fare lo swap dei buffers
  (use-package ace-window
  :ensure t
  :bind
  (("M-o" . ace-swap-window))) ; esempio default
  ;;il comando di base per cambiare focus è C-x o

;;GESTIONE UI

(global-display-line-numbers-mode 1)
(tool-bar-mode -1) ;disattivazione tool bar(superflua se sai i comandi)
(scroll-bar-mode -1) ;disattivazione scrollbar(ho già indicazione nella modeline
(menu-bar-mode 1)  ;disattivazione della menu bar
;Quando disattivi menu-bar,ivy da una versione semplificata non intuitiva
;;per disattivarla e usare quella vera fai così:
;;(setq ivy-use-virtual-buffers t)  ;; Usa solo buffer virtuali
;;(setq ivy-initial-inputs-alist nil)  ;; Disabilita la modalità a discesa per il completamento
(global-set-key (kbd "<f9>") 'menu-bar-mode)  ;; Apre/chiude la menu bar con pulsante F9
(global-set-key (kbd "<f11>") #'toggle-frame-fullscreen) ;; Toggle-Frame-Fullscreen
;;(define-key corfu-map (kbd "<f11>") nil)
;;utilizzo di eldoc per avere tipo lsp senza lsp
(global-eldoc-mode 0) 
;(global-corfu-mode 0)
(global-ede-mode t)


(use-package eldoc-box
  :disabled t)


;;markdown mode
(use-package markdown-mode
  :defer t
  :ensure t)

;;per avere home come buffer iniziale
;;(setq initial-buffer-choice (lambda () (find-file "~")))

;;nerd-icons
(use-package nerd-icons
  :ensure t)

;; Abilita l'interfaccia di completamento
(use-package ivy
  :ensure t
  :config
  (ivy-mode 1))

;;nascondere la modeline di emacs con scorciatoia da tastiera
(use-package hide-mode-line
  :ensure t
  :defer t )
;;scorciatoia per nasconder la modeline a piacimento
(global-set-key (kbd "<f8>") #'hide-mode-line-mode)
;;chiamo ibuffer per vedere i buffer aperti


;;ORG-MODE
    ;;CUSTOM/FUNZIONI PER ORG-MODE
           ;;cursore di org-mode all'inizio del file,non in fondo
           (add-hook 'find-file-hook
                     (lambda ()
                       (when (string-equal (file-name-extension buffer-file-name) "org")
                         (goto-char (point-min)))))

           ;;Org-download
           (use-package org-download
             :ensure t
	     :defer t
             :config
             (setq org-download-directory "~/Immagini/Schermate/")
             (global-set-key (kbd "C-x C-d") 'org-download-screenshot))
           ;;pacchetto Yas-Snippet
           (use-package yasnippet
             :ensure t
             :config
             (yas-global-mode 1)
           )
           ;;pacchetto ox reveal per usare org-re-reveal/org-reveal
         ;  (use-package ox-reveal)
         ;pandoc/ox-pandoc
           (add-to-list 'exec-path "/home/Pandoc")
					;ORG-MODE-LATEX-GRAFICI
           (setq org-latex-pdf-process
                 '("pdflatex -interaction nonstopmode %f"
                   "pdflatex -interaction nonstopmode %f"))

           ;;visualizzare immagini con emacs per org mode
           (setq org-startup-with-inline-images t)
(setq org-display-inline-images t)

           ;;visualizzare immagini con emacs per org mode
           (setq org-startup-with-inline-images t)
           (setq org-display-inline-images t)
           ;;eseguire codice matlab dentro emacs(per org mode)
           ;;matlab nodisplay nosplash matlab deve essere aggiunto al path
           (setq org-babel-matlab-command "matlab -nodisplay -nosplash -r")
           ;;(add-to-list 'org-babel-load-languages'(matlab . t))
           ;;per usare il pacchetto gnuplot  
           ;;per caricare le formule scritte in latex direttamente visibili
                      ;;ogni volta che apro i file utilizzo questo,farlo ogni volta
           ;;Ã¨ una rottura e non sono riuscito a farlo ancora in un blocco src latex
           ;;(setq org-preview-latex-default-process 'dvipng)


  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (shell . t)
     (java . t)
     (latex . t)
     (matlab . t)
     (python . t)))


;; Impostazioni per utilizzare MATLAB/Octave in Emacs
;;(executable-find matlab-executable)
;; Aggiunta del percorso all'eseguibile
(setq matlab-executable "/home/mattia/MATLAB/esercizi") ;;  modifica il percorso secondo la tua installazione
(add-to-list 'exec-path "/home/mattia/MATLAB/esercizi/lavori")

;; Attivazione automatica di matlab-mode per file .m
(add-to-list 'auto-mode-alist '("\\.m$" . matlab-mode))
;(add-to-list 'auto-mode-alist '("\\.m$" . octave-mode))

;; Messaggio di avvio
(add-hook 'matlab-mode-hook
          (lambda () (message "MATLAB è stato avviato!")))

;; Configurazioni di indentazione
(setq matlab-indent-function t)
(setq matlab-block-offset 4)
(setq matlab-fill-code nil)
(setq matlab-verify-on-save-flag nil)

;; Funzione per aprire buffer MATLAB
(defun matlab-buffer ()
  "Restituisce il nome del buffer MATLAB."
  "*MATLAB*")

;; Hook per aprire buffer quando si apre un .m
(add-hook 'after-find-file-hook
          (lambda ()
            (when (and (eq major-mode 'matlab-mode)
                       (string-match "\\.m\\'" (buffer-file-name)))
              (switch-to-buffer (matlab-buffer)))))

        ;; Hook per aprire il buffer Octave quando si apre un file .m
    ;    (add-hook 'after-find-file-hook
   ;               (lambda ()
     ;               (when (and (eq major-mode 'octave-mode)
      ;                         (string-match "\\.m\\'" (buffer-file-name)))
       ;               (switch-to-buffer (octave-buffer)))))
        ;; Funzione per inviare comandi a GNU Octave
      ;  (defun octave-send-command (command)
       ;   "Invia un comando a GNU Octave, avviandolo se necessario."
        ;  (let ((octave-process (or (get-process "gnu-octave")
         ;                           (octave-start))))
          ;  (process-send-string octave-process (concat command "\n"))))



;; EMMS: musica e video con MPV
(use-package emms
  :ensure t
  :defer t
  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (emms-all)
  (emms-default-players)
  (emms-mpris-enable)
  :custom
  (emms-browser-covers #'emms-browser-cache-thumbnail-async)
  :bind
  (("C-c w m b" . emms-browser)
   ("C-c w m e" . emms)
   ("C-c w m p" . emms-play-playlist )
   ("<XF86AudioPrev>" . emms-previous)
   ("<XF86AudioNext>" . emms-next)
   ("<XF86AudioPlay>" . emms-pause)))

(defun dired-play-video-with-mpv ()
  "Riproduce il file video selezionato in Dired con MPV."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (start-process "mpv-video" nil "mpv" "--force-window=yes" "--quiet" file)))
;; Imposta la directory musicale di default
(setq emms-source-file-default-directory "~/Musica/e-onkyo music")


;;nascondere il titoli  dai guardoni cagacazzo è la scelta migliore
;; Toggle per nascondere/mostrare i titoli in EMMS
(defun my-emms-toggle-titles ()
  "Alterna tra mostrare e nascondere i titoli delle canzoni in EMMS."
  (interactive)
      ;; Se attualmente mostra i titoli  nascondi
      (setq emms-track-description-function
            (lambda (track) ""))
    ;; Altrimenti  ripristina la visualizzazione standard
    (setq emms-track-description-function
          'emms-track-simple-description))

;; Scorciatoia globale (C-c t)
(global-set-key (kbd "C-c t") 'my-emms-toggle-titles)
;; Assegna la funzione al tasto V in Dired per vedere un video
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "V") 'dired-play-video-with-mpv))
;; Read ePub files
(use-package nov  ;;utilizza il pacchetto nov.el di Schneidermann
  :ensure t
  :defer t
    :init
    (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))
;;pacchetto pdf-tools
(use-package pdf-tools
  :ensure t
 ; :defer t
  :config
  (pdf-tools-install))
;;risoluzione di docview
;;caratteri testo di docview e antialiasing
(setq doc-view-resolution 180) ;; Imposta la risoluzione a 200

  ;; Aggiungi pacchetti LaTeX se ti servono
   (setq org-latex-packages-alist
         '(("" "graphicx")
           ("" "amsmath")
           ("" "hyperref")))

 ;; Aggiunta del percorso di Octave all'ambiente di Emacs
 ;  (add-to-list 'exec-path "/home/mattia/.config/octave")



;;IMPOSTO BASH COME SHELL DEFAULT DI VTERM
(setq vterm-shell "/bin/bash")

  ;;DISABILITO I BACKUP E AUTOSAVE
  (setq make-backup-files nil)  ;; Disabilita i file di backup (~)
  (setq auto-save-default nil)  ;; Disabilita il salvataggio automatico


;(declare-function cape-keyword "cape")
;(declare-function emms-all "emms")
;(declare-function emms-default-players "emms")
;(declare-function emms-mpris-enable "emms")
;(declare-function c-toggle-auto-newline)


(setq native-comp-async-report-warnings-errors nil)


;;settiamo dei default atti a semplificare/facilitare e velocizzare la scrittura di testo/codice
;; Flyspell per testi (Org, Markdown, commenti)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (add-hook 'text-mode-hook 'flyspell-mode)					    ;;
;; ;; Popup moderno								    ;;
;; ;(add-hook 'text-mode-hook #'corfu-mode)					    ;;
;; ;; Imposta dizionari								    ;;
;; ;(setq ispell-dictionary "italian")						    ;;
;; ;(setq ispell-local-dictionary "italian")					    ;;
;; ;(setq ispell-dictionary-alist						    ;;
;;  ;     '(("italian" "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-d" "it_IT") nil utf-8)   ;;
;;   ;      ("english" "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-d" "en_US") nil utf-8)   ;;
;;    ;     ("french"  "[A-Za-z]" "[^A-Za-z]" "[']" nil ("-d" "fr_FR") nil utf-8))) ;;
;; ;;per passare a quello inglese: M-x ispell-change-dictionary RET english	    ;;
;; ;; Flyspell nei commenti del codice						    ;;
;; (add-hook 'prog-mode-hook #'flyspell-prog-mode)				    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Attiva parentesi automatiche
(electric-pair-mode 1)
;; Indentazione automatica quando premi RET
(electric-indent-mode 1)

;;auto new line per i linguaggi di programmazione che uso
(add-hook 'c-mode-common-hook
          (lambda ()
            (c-toggle-auto-newline 1)))

(setq-default mode-line-format
  (list
   '(:eval (concat " " (nerd-icons-icon-for-mode major-mode) " "))
   'mode-line-buffer-identification
   "   "
   'mode-line-position
   "  "
   'mode-line-modes
   'mode-line-misc-info))


;;ZOOM:lo zoom con ctrl + rotella è impostato di default da emacs,aggiungo  quello senza mouse(ctrl ++ e ctrl --)
    (global-set-key (kbd "C-+") 'text-scale-increase)
    (global-set-key (kbd "C--") 'text-scale-decrease)
    ;; Abilita il supporto per il copia e incolla con il sistema
    (setq x-select-enable-clipboard t)
    ;; Visualizza il numero della colonna corrente nella barra di stato
    (column-number-mode 1)
    ;;Aumenta la soglia per garbage collector(GC) a 100MB
    (setq gc-cons-threshold (* 100 1024 1024))
    ;;imposta default valore del GC quando emacs non Ã¨ attivo
    (add-hook 'emacs-startup-hook
              (lambda ()
                (setq gc-cons-threshold (* 2 1024 1024))))

    (setq large-file-warning-threshold 100000000) ;;supporto file olte 100 MB


;;SETUP EGLOT
(use-package eglot)
(use-package eglot-java
  :requires eglot
  :config
  (progn
    (add-hook 'java-mode-hook 'eglot-java-mode)))


;;DASHBOARD
;;abilita le icone della dashboard
;;(print (font-family-list))
;(use-package all-the-icons)
;(use-package nerd-icons
; :ensure t)
(use-package dashboard
  :ensure t
  :config
  ;; Logo: PNG in GUI, ASCII centrato in terminale/TTY
  (if (display-graphic-p)
      (setq dashboard-startup-banner "~/.emacs.d/loghi-emacs/gnu_color.png")
    (setq dashboard-startup-banner 'logo
          dashboard-ascii-banner-centered t))

  ;; Disattiva backend Projectile (usa project.el)
  (setq dashboard-projects-backend 'project-el)
  ;; Opzioni estetiche
  ;;(setq dashboard-startup-banner "~/.emacs.d/loghi-emacs/gnu_color.png")
  (setq dashboard-center-content t)
  (setq dashboard-show-shortcuts t)
  ;(setq dashboard-set-file-icons t)
  (setq dashboard-set-heading-icons t) ;; <-- corretto
  ;; Cosa mostra la Dashboard
  (setq dashboard-items '((recents  . 7)
                          (projects . 5)))
  ;; Avvia la dashboard
  (dashboard-setup-startup-hook))

;; Abilita dashboard
(dashboard-setup-startup-hook)
;;centro la dashboard verticalmente
(defun my/dashboard-center-vertically ()
  "Center dashboard content vertically."
  (let ((margin-top (max 0 (/ (- (frame-height) (+ (count-lines (point-min) (point-max)) 2)) 2))))
    (dashboard-insert-ascii-banner )
    (insert (make-string margin-top ?\n))))



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(wombat atom-dark))
 '(custom-safe-themes
   '("ca1b398ceb1b61709197478dc7f705b8337a0a9631e399948e643520c5557382"
     "a5c590aeb7dc5c2b8d36601a4c94a1145e46bd2291571af02807dd7a8552630c"
     default))
 '(package-selected-packages
   '(ace-window atom-dark-theme atom-one-dark-theme auctex cuda-mode
		dashboard devdocs dired-sidebar eglot-java emms
		hide-mode-line ivy lv markdown-mode matlab-mode
		nerd-icons-dired nov org-download
		organize-imports-java pdf-tools spinner vterm
		yasnippet)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

