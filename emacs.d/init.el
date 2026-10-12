;(setq-default mode-line-format (default-value 'mode-line-format))  -*- lexical-binding: t; -*-
;(require 'package)
;; Aggiunge MELPA come archivio di pacchetti
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;(setq use-package-always-defer t)
;;aggiunta al path di emacs di pdflatex e altro
(add-to-list 'exec-path "/usr/bin/latex")
(add-to-list 'exec-path "/usr/bin/pdflatex")
(add-to-list 'exec-path "/usr/bin/pandoc")

;;caricamento del tema custom di emacs
(load-file (expand-file-name "~/.emacs.d/lisp/custom-theme-ONE.el"))

;caricamento di ewm quando configurato
(xterm-mouse-mode t) ;;supporto del mouse in TTY e terminale attivati
;; Disabilita l'avviso per lexical-binding durante la byte-compilazione
(setq byte-compile-warnings '(not lexical))
(setq warning-suppress-types '((defvaralias)(lexical)))
;; O in alternativa, evita del tutto l'apertura automatica del buffer *Warnings*
;; per i warning minori

;;(setq flycheck-navigation-minimum-level :error)
(setq warning-minimum-level :error)
(setq use-package-compute-statistics t)
(setq native-comp-async-report-warnings-errors nil)
;;font settings
;; Imposta il font principale
;(defvar my/default-font "Source Code Pro Medium 11")
;; Applica il font al frame corrente
;(set-face-attribute 'default nil :font my/default-font)
;;cursore che lampeggia e tipo
(blink-cursor-mode 1)
;(setq-default cursor-type 'bar)
;;aumento la dimensione del fringe
(set-fringe-mode '(12 . 8))
;;enable context menu
(context-menu-mode 1)

;; =============================================================================
;; SETUP EGLOT & JAVA LSP
;; =============================================================================

(use-package eglot
   :ensure t
   :defer t
   :hook ((c-ts-mode
           c++-ts-mode
           python-ts-mode
           bash-ts-mode) . eglot-ensure)
  :hook (java-ts-mode . (lambda ()
                          (require 'eglot-java)
                          (eglot-java-mode)
                         (eglot-ensure)))
   :init
   ;:config
   ;; Disabilita il workspace temporaneo continuo per Java
   ;; (setq eglot-workspace-configuration
   ;;       '(:java (:workspace (:path "~/.emacs.d/jdtls-workspace"))))
   (setq-default eglot-workspace-configuration
                '(:java (:workspace (:path "~/.emacs.d/jdtls-workspace")
                         :semanticHighlighting (:enabled :json-false)
                         :inlayHints (:parameterNames (:enabled "none")))))
   :config
   ;; Disattiva solo il Semantic Highlighting di Eglot (lascia gestire i colori a tree-sitter)
   (add-to-list 'eglot-stay-out-of 'font-lock)
   (setq eglot-events-buffer-size 0)
   (setq eglot-send-changes-idel-time 0.5)
   ; Ignora i semantic token
     (add-to-list 'eglot-ignored-server-capabilities :semanticTokensProvider)
)


(use-package eglot-java
  :ensure t
  :after eglot
  :hook (java-ts-mode . (lambda ()
  ;; Forza l'esclusione di font-lock anche all'interno del buffer Java
                          (setq-local eglot-stay-out-of '(font-lock))
			  (eglot-java-mode)
                          (eglot-ensure)))
  :config
  (add-hook 'java-ts-mode-hook #'eglot-java-mode)
  ;; Impedisce a eglot-java di applicare i propri face personalizzati
  (setq eglot-java-eclipse-jdtls-custom-args '("-Declipse.override-font-lock=false")))

;; Scorciatoie tastiera e mouse sul fringe e fuori per Eglot Code Actions
(with-eval-after-load 'eglot
  ;; Mappature per il mouse
  ;(define-key eglot-mode-map (kbd "<left-fringe> <mouse-3>") #'eglot-code-actions)
  ;(define-key eglot-mode-map (kbd "<left-margin> <mouse-3>") #'eglot-code-actions)
  ;; Mappatura da tastiera (stile Zed/VS Code)
  (define-key eglot-mode-map (kbd "C-.") #'eglot-code-actions))


;;aggiunta di eglot e/o dape al context menu
(defun my-eglot-context-menu (menu click)
  "Aggiunge i comandi Eglot al menu del tasto destro."
  (when (and (derived-mode-p 'prog-mode)
             (bound-and-true-p eglot--managed-mode))
    ;; Aggiunge un separatore e poi la voce per le Code Actions
    (define-key-after menu [eglot-sep] '("--"))
    (define-key-after menu [eglot-code-actions]
      '(menu-item "LSP Code Actions" eglot-code-actions
                  :help "Esegue le azioni di codice LSP"))

      (define-key-after menu [eglot-rename]
        '(menu-item "LSP Rename Symbol" eglot-rename
                    :help "Rinomina il simbolo nel progetto"))

      (define-key-after menu [eglot-format]
        '(menu-item "LSP Format Buffer" eglot-format
                    :help "Formatta il codice del buffer"))

      (define-key-after menu [xref-find-definitions]
        '(menu-item "Go to Definition" xref-find-definitions
                    :help "Vai alla definizione del simbolo")))
  menu) ; IMPORTANTE: restituire sempre 'menu' alla fine!
;; Attiva l'interfaccia e registra la funzione hook
(add-hook 'context-menu-functions #'my-eglot-context-menu)


;;Flycheck
(use-package flycheck
 :ensure t
 :defer t
 ;:init
 ;(global-flycheck-mode t)
 :config
 (setq flycheck-display-errors-delay 0.1)
 ;(setq flycheck-display-errors-function #'flycheck-display-error-messages-inline)
 (flycheck-annotate-mode t)
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))


;;Flycheck-eglot
(use-package flycheck-eglot
  :ensure t
  :after eglot
  :config
  (global-flycheck-eglot-mode 1)
					;(flycheck eglot-mode))
  )

(add-hook ' eglot-managed-mode-hook
	    (lambda()
	      (flymake-mode -1)
	      (flycheck-eglot-mode 1)))


;;disattivo flymake problematico con eglot
;;eldoc box attivo automaticamente per eglot lsp



;async emacs
(use-package async
  :defer t
  :ensure t)

;recentf:file recenti
(use-package recentf
  :ensure nil ;; Pacchetto built-in
  :init
  (recentf-mode 1)
  :config
  ;; Aumenta il numero massimo di file salvati a 50 (modificabile a piacere)
  (setq recentf-max-saved-items 50)
  (setq recentf-max-menu-items 30))



;;REPEAT:permette di ripetere il comando da tastiera premendo una sola lettera
(use-package repeat
  :ensure t
  :defer t
  :custom
  (repeat-mode +1))

;;CONFIGURAZIONE Debugger GUD
(use-package gud
  :defer t
  :ensure nil ;; Pacchetto built-in
  :config
  (setq gud-tooltip-mode t)

  ;; =============================================================================
  ;; GESTIONE FINESTRA GUD/JDB (EVITA SCHERMO INTERO)
  ;; =============================================================================

  (with-eval-after-load 'gud
    ;; Forza il buffer *gud-jdb* o *gud-* ad aprirsi in basso occupando il 30% dell'altezza
    (add-to-list 'display-buffer-alist
		 '("\\*gud-.*\\*"
                   (display-buffer-in-side-window)
                   (side . bottom)
                   (slot . 1)
                   (window-height . 0.3)
                   (reusable-frames . nil))))

  ;; Mantiene il buffer del codice sorgente focalizzato all'avvio del breakpoint
  (setq gud-goto-untagged-buffer t)


  ;; BREAKPOINT CON TASTO SINISTRO DEL MOUSE
  (defun my/gud-toggle-breakpoint-mouse (event)
    "Imposta o rimuove un breakpoint GUD cliccando sul margine sinistro."
    (interactive "e")
    (mouse-set-point event)
    (if (bound-and-true-p gud-comint-buffer)
        (if (fboundp 'gud-break)
            (gud-break nil)
          (gud-call "break %f:%l"))
      (message "Nessuna sessione GUD attiva, avvia con F5.")))

  ;; Assegna il click del tasto sinistro sul margine/fringe
  (global-set-key (kbd "<left-fringe> <mouse-1>") #'my/gud-toggle-breakpoint-mouse)
  (global-set-key (kbd "<left-margin> <mouse-1>") #'my/gud-toggle-breakpoint-mouse)

  ;; AVVIO AUTOMATICO IN BASE AL LINGUAGGIO
  (defun my/gud-start-for-current-mode ()
    "Avvia il debugger GUD appropriato in base alla major-mode."
    (interactive)
    (pcase major-mode
      ((or 'java-mode 'java-ts-mode)
       (let ((class-name (file-name-base (buffer-file-name))))
         (jdb (read-string "Comando JDB: " (format "jdb %s" class-name)))))
      ((or 'c-mode 'c-ts-mode 'c++-mode 'c++-ts-mode)
       (gdb (read-string "Comando GDB: " (format "gdb -i=mi %s" (file-name-base (buffer-file-name))))))
      ((or 'python-mode 'python-ts-mode)
       (pdb (read-string "Comando PDB: " (format "python -m pdb %s" (file-name-nondirectory (buffer-file-name))))))
      (_
       (call-interactively #'jdb))))

  (global-set-key (kbd "<f5>") #'my/gud-start-for-current-mode)

;; Integrazione nel menu "Tools"
(defun my/add-gud-menu-to-prog-mode ()
  (easy-menu-add-item
   nil
   '("Tools")
   ["GUD" gud-menu-map t]
   "Compare"))

(add-hook 'prog-mode-hook #'my/add-gud-menu-to-prog-mode))


;;Doom modeline
(use-package doom-modeline
  :ensure t
  :defer t
  :hook (emacs-startup . doom-modeline-mode)
  :config
  ;; Disabilita il caricamento prematuro di icone complesse prima del rendering
  (setq doom-modeline-icon t
        doom-modeline-height 28
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-file-name-style 'truncate-with-project))

;;nascondere la modeline
(use-package hide-mode-line
  :ensure t
  :defer t)
(global-set-key (kbd "<f8>") #'hide-mode-line-mode)

;; Disabilita la schermata di benvenuto e apre *scratch* come buffer iniziale
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(setq inhibit-startup-screen t)                                                    ;;
;(setq initial-buffer-choice t)                                                     ;;
;; ;; Apre la dired-sidebar automaticamente solo dopo che l'interfaccia si è caricata ;;
;(add-hook 'emacs-startup-hook #'dired-sidebar-toggle-sidebar)                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;GESTIONE UI
(global-display-line-numbers-mode t)
(global-set-key (kbd "<f9>") 'menu-bar-mode)  ;; Apre/chiude la menu bar con pulsante F9
(global-set-key (kbd "<f11>") #'toggle-frame-fullscreen) ;; Toggle-Frame-Fullscreen
;;utilizzo di eldoc
(global-eldoc-mode 1)
;;posso implementare livelli diversi di evidenziazione e identazione
(setq treesit-font-lock-level 4)
;; Attiva parentesi automatiche
(electric-pair-mode 1)
;; Indentazione automatica quando premi RET
(electric-indent-mode 1)
;; Attiva l'anteprima su tutti i file di codice
;(add-hook 'prog-mode-hook #'completion-preview-mode)
;; Attiva il folding nei buffer di codice
(add-hook 'prog-mode-hook #'outline-minor-mode)
;; Attiva il rientro automatico nei commenti
(add-hook 'prog-mode-hook #'auto-fill-mode)
(setq-default fill-column 80) ; Lunghezza massima riga
;; Attiva Glasses Mode solo dove serve(non modifica il file vero,solo migliora la leggibilità
(add-hook 'java-ts-mode-hook #'glasses-mode)
;; Per accettare il suggerimento con TAB quando compare:
;; (mantiene TAB per l'indentazione normale se l'anteprima non c'è)
;(keymap-set completion-preview-active-mode-map "TAB" #'completion-preview-insert)
;; Opzionale: fa sì che premendo TAB il cursore prima indenti la riga
;; e, se è già indentata, mostri subito i suggerimenti LSP/Eglot
(setq tab-always-indent 'indent)

;; Va a capo automaticamente dopo aver digitato ';' nei file di codice (Java, C, C++)
(defun my/setup-semicolon-newline ()
  "Imposta l'a capo automatico dopo il punto e virgola."
  (setq-local electric-layout-rules '((?\; . after)))
  (electric-layout-mode 1))
;; Attiva la regola nei linguaggi di programmazione (incluso java-ts-mode)
(add-hook 'prog-mode-hook #'my/setup-semicolon-newline)

;;DISABILITO I BACKUP E AUTOSAVE
(setq make-backup-files nil)  ;; Disabilita i file di backup (~)
(setq auto-save-default nil)  ;; Disabilita il salvataggio automatico



;;siccome tresitter è già integrato in emacs e ha delle funzioni,si sta
;;espandendo e tra qualche anno potrebbe
;;essere il nuovo default e le altre in legacy-mode,allora lo settiamo subito
;;dovrebbe anche essere più
;;veloce mentre lo si utilizza delle major mode con regexp e più preciso in parsing e
;;syntax highlighting
;;utilizza major-mode-remap-alist per sostituire le vecchie modes con quelle treesitter
(setq major-mode-remap-alist
      '((c-mode          . c-ts-mode)
        (c++-mode        . c++-ts-mode)
        (c-or-c++-mode   . c-or-c++-ts-mode)
        (java-mode       . java-ts-mode)
        (sh-mode         . bash-ts-mode)
        (bash-mode       . bash-ts-mode)
        (python-mode     . python-ts-mode)
        (json-mode       . json-ts-mode)
        (js-mode         . js-ts-mode)
        (javascript-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (tsx-mode        . tsx-ts-mode)
        (css-mode        . css-ts-mode)
        (html-mode       . html-ts-mode)
        (yaml-mode       . yaml-ts-mode)
        (toml-mode       . toml-ts-mode)
        (dockerfile-mode . dockerfile-ts-mode)
        (cmake-mode      . cmake-ts-mode)
        (csharp-mode     . c-sharp-ts-mode)
        (ruby-mode       . ruby-ts-mode)
        (rust-mode       . rust-ts-mode)
        (go-mode         . go-ts-mode)
        (gomod-mode      . gomod-ts-mode)
        (elixir-mode     . elixir-ts-mode)
        (heex-mode       . heex-ts-mode)
        (latex-mode      . latex-ts-mode)))


;;Aggiunta del support di matlab-mode in aggiunta a octave-mode,che al momento è disattivato,averli attivi insieme funziona lo stesso ma mette il simbolo
;;errato e comuneque non gli voglio attivi magari contempoeranemante quando apro un file .m,che entrambi aprono
;; Impostazioni per utilizzare MATLAB/Octave in Emacs
;;(executable-find matlab-executable)
;; Aggiunta del percorso all'eseguibile

(use-package matlab-mode
  :ensure t
  :defer t
  :init
;init esegue subito all'avvio
; modifica il percorso secondo la tua installazione
(add-to-list 'exec-path "$HOME/MATLAB/esercizi/lavori")
;; Attivazione automatica di matlab-mode per file .m
(add-to-list 'auto-mode-alist '("\\.m$" . matlab-mode))
;(add-to-list 'auto-mode-alist '("\\.m$" . octave-mode))
  :config
  ;; Configurazioni di indentazione
  (setq matlab-indent-function t)
  (setq matlab-block-offset 4)
  (setq matlab-fill-code nil)
  (setq matlab-verify-on-save-flag nil)
;; Hook di caricamento e Messaggio di avvio
(add-hook 'matlab-mode-hook
          (lambda () (message "MATLAB è stato avviato!")))
;; Configurazioni di indentazione
; (setq matlab-indent-function t)
; (setq matlab-block-offset 4)
; (setq matlab-fill-code nil)
; (setq matlab-verify-on-save-flag nil)
;; Funzione per aprire buffer MATLAB
(defun matlab-buffer ()
  "Restituisce il nome del buffer MATLAB."
  "*MATLAB*")
;; Hook per aprire buffer quando si apre un .m
(add-hook 'after-find-file-hook
          (lambda ()
            (when (and (eq major-mode 'matlab-mode)
                       (string-match "\\.m\\'" (buffer-file-name)))
              (switch-to-buffer (matlab-buffer))))))

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

                                        ;ORG-MODE
;;CUSTOM/FUNZIONI PER ORG-MODE
;;cursore di org-mode all'inizio del file,non in fondo
(add-hook 'find-file-hook
          (lambda ()
            (when (string-equal (file-name-extension buffer-file-name) "org")
              (goto-char (point-min)))))


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
;;eseguire codice matlab dentro emacs(per org mode)
;;matlab nodisplay nosplash matlab deve essere aggiunto al path
;(setq org-babel-matlab-command "matlab -nodisplay -nosplash -r")
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
   (plantuml .t)))


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

;; ;;ZOOM:lo zoom con ctrl + rotella è impostato di default da emacs,aggiungo
;; ;;quello senza mouse(ctrl ++ e ctrl --)
 (global-set-key (kbd "C-+") 'text-scale-increase)
 (global-set-key (kbd "C--") 'text-scale-decrease)
;; ;; Abilita il supporto per il copia e incolla con il sistema
;; (setq x-select-enable-clipboard t)


;; EMMS: musica e video con MPV
(use-package emms
  :ensure t
  :defer t
  :commands (emms emms-browser)
  :init
  (with-eval-after-load 'emms
    (require 'emms-setup)
    (require 'emms-mpris)
    (require 'emms-browser)
    (emms-standard)
    (emms-default-players)
    (emms-mpris-enable))
  :custom
  (emms-browser-covers #'emms-browser-cache-thumbnail-async)
  (setq emms-source-file-default-directory "~/Musica/e-onkyo music")
  :bind
  (("C-c w m b" . emms-browser)
   ("C-c w m e" . emms)))

  (defun dired-play-video-with-mpv ()
    "Riproduce il file video selezionato in Dired con MPV."
    (interactive)
    (let ((file (dired-get-file-for-visit)))
      (start-process "mpv-video" nil "mpv" "--force-window=yes" "--quiet" file)))
  ;;nascondere il titoli  dai guardoni cagacazzo è la scelta migliore
  ;; Toggle per nascondere/mostrare i titoli in EMMS
;; Assegna la funzione al tasto V in Dired per vedere un video
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "V") 'dired-play-video-with-mpv))



;; Visualizza il numero della colonna corrente nella barra di stato
(column-number-mode 1)


;;DIRED SIDEBAR MODIFICHE:lazy loaded per evitare sia caricata quando non serve
(use-package dired-sidebar
  :ensure t
  :commands (dired-sidebar-show-sidebar dired-sidebar-toggle-sidebar)
  :bind ("<f7>" . dired-sidebar-toggle-sidebar)
  :hook
  ;; Doom modeline nella sidebar
  (dired-sidebar-mode . doom-modeline-mode)
  ;; Niente numeri di riga nella sidebar
  (dired-sidebar-mode . (lambda () (display-line-numbers-mode -1)))
  :custom
  ;; 1. Fai seguire automaticamente il file attivo nel buffer
  (dired-sidebar-follow-file t)
  ;; 2. Attiva il tema con icone moderne (richiede il pacchetto nerd-icons o all-the-icons)
  (dired-sidebar-theme 'nerd)
  ;; Impostazioni dimensionali e font
  (dired-sidebar-width 27)
  (dired-sidebar-use-custom-font t))




;;pdf.tools
(use-package pdf-tools
  :ensure t
  :defer t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install)
  (with-eval-after-load 'pdf-view
  (setq pdf-view-incompatible-modes (delete 'display-line-numbers-mode pdf-view-incompatible-modes)))
  ;; Disabilita i numeri di riga dentro pdf-view-mode
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1))))


;;ghostel è ben più veloce di vterm ed è meglio come terminale classico in emacs,come rendering per nano e altro
(use-package ghostel
  :ensure t
  :defer t
  )
  (ghostel-comint-global-mode t)
  (ghostel-compile-global-mode t)

;;Flyspell
(use-package flyspell
 :ensure t
  :defer t
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
  :defer t
  :bind
  (("M-o" . ace-swap-window))) ; esempio default
;;il comando di base per cambiare focus è C-x o


;;nerd-icons
(use-package nerd-icons
  :ensure t
  :defer t)

(use-package vertico
  :ensure t
  :defer t
  :custom
  (vertico-count 12)       ; Numero di candidati da mostrare
  (vertico-resize t)       ; Ridimensiona dinamicamente il minibuffer
  (vertico-cycle t)        ; Scorri in ciclo quando arrivi in fondo alla lista
  :init
  (vertico-mode 1))



;;comandi avanzati con consult
(use-package consult
  :defer t
  :ensure t)

;;stile di completamento con M-x
(use-package orderless
  :ensure t
  :init
  ;; Imposta Orderless come stile di completamento
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((command (styles orderless)) ;;stile
                                        (file (styles orderless))  ;file
                                        (symbol (styles orderless)))))  ;;simbolo

;; Read ePub files
(use-package nov  ;;utilizza il pacchetto nov.el di Schneidermann
  :ensure t
  :defer t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

;;risoluzione di docview
;;caratteri testo di docview e antialiasing
;(setq doc-view-resolution 180) ;; Imposta la risoluzione a 200

;; Aggiungi pacchetti LaTeX se ti servono
(setq org-latex-packages-alist
      '(("" "graphicx")
        ("" "amsmath")
        ("" "hyperref")))

;; Aggiunta del percorso di Octave all'ambiente di Emacs
;; (add-to-list 'exec-path "/home/mattia/.config/octave")


;; ;ement(matrix-client)
;; (use-package ement
;;   :defer t
;;   :ensure t)



;pandoc
(use-package pandoc
  :defer t
  :ensure t)

;pandoc-mode
(use-package pandoc-mode
  :defer t
  :ensure t)

;ox-pandoc
(use-package ox-pandoc
  :defer t
  :ensure t)

;mpvi
(use-package mpvi
  :defer t
  :ensure t)

;scarica auctex di emacs invece che di sistema
(use-package auctex
  :defer t
  :ensure t)

;;configurazione magit
;; (use-package magit
;;   :defer t
;;   :ensure t)

;CONFIGURIAMO ELFEED
(use-package elfeed
  :defer t
  :ensure t
  :config
  (setq elfeed-feeds
        '(
          ;; Emacs
          ("https://planet.emacslife.com/atom.xml" emacs)
          ("https://sachachua.com/blog/feed/" emacs)
          ("https://irreal.org/blog/?feed=rss2" emacs)
          ("https://www.gnu.org/software/emacs/rss.xml" emacs)
          ;; Fotografia
          ("https://www.35mmc.com/feed/" photo)
          ("https://phillipreeve.net/blog/feed/" photo)
          ("https://www.thephoblographer.com/feed/" photo)
          ("https://mrleica.com/feed/" photo)
	  ("https://tahusa.co/feed/" photo)
	  ;; non ha un feed rss ("https://www.juzaphoto.com/home.php?l=it" photo)
	  ;;fred miranda non ha rss feed
	  ;; Linux
	  ("https://news.opensuse.org/feed.xml" linux)
	  ;; Elettronica
	  ("https://www.eevblog.com/feed/" elettronica)
          ;; YouTube (via RSS)
          ("https://www.youtube.com/feeds/videos.xml?channel_id=UCRte2QViSKBN5tM5YL7tTcg" youtube)
          ("https://www.youtube.com/feeds/videos.xml?channel_id=UCknMR7NOY6ZKcVbyzOxQPhw" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCs52U_Q9TYSHtd9oxD4WN0A" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCxSiyTe60iQAY1UqCylNMmw" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC05XpvbHZUQOfA6xk4dlmcw" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCkgqk1hG-E0qINRY8k5VTng" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCHZIqNx-vU_PX8OArquXw_g" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCp_5PO66faM4dBFbFFBdPSQ" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCIdYIrInVnUwHVbogLj6bqA" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCsaGKqPZnGp_7N80hcHySGQ" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCZb8uqR_73t8DlfpVfVbiEw" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCIEv3lZ_tNXHzL3ox-_uUGQ" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCOTGxmnJatVdD1QOZs0rriA" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCeMbZC8Uv9uJArqFQnFCDNQ" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC7YOGHUfC1Tb6E4pudI9STA" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCgkw_MMOy6k1wGN9VM3kKOA" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCqNkn5PNeSqbQTAR5RP-L-Q" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCp3yVOm6A55nx65STpm3tXQ" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCNLRcEn78Vc62C3GkMvBgtA" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UC2DjFE7Xf11URZqWBigcVOQ" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCJQkHVpk3A8bgDmPlJlOJOA" youtube)
	  ("https://www.youtube.com/feeds/videos.xml?channel_id=UCRte2QViSKBN5tM5YL7tTcg" youtube)
          )))

(use-package elfeed-tube
  :ensure t
  :after elfeed
  :bind (:map elfeed-show-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save)
              :map elfeed-search-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save))
:config
(with-eval-after-load 'elfeed-tube
  (elfeed-tube-setup)))

(use-package elfeed-tube-mpv
  :ensure t
  :after elfeed-tube
  :bind (:map elfeed-show-mode-map
              ("C-c C-f" . elfeed-tube-mpv-follow-mode)
              ("C-c C-w" . elfeed-tube-mpv-where))
:config
(with-eval-after-load 'elfeed-tube-mpv
  (define-key elfeed-show-mode-map (kbd "V") #'elfeed-tube-mpv)))
;;scorciatoia per elfeed
(global-set-key (kbd "C-c e") #'elfeed)


;;compile angeal per avere sia bytecode che nativecomp degli stessi file
;;massimizzando performance
(use-package compile-angel
  :defer t
  :ensure t
  :demand t
  :config
  ;; Set `compile-angel-verbose' to nil to disable compile-angel messages.
  ;; (When set to nil, compile-angel won't show which file is being compiled.)
  (setq compile-angel-verbose t)
  (setq compile-angel-compile-style 'both)
  ;; The following directive prevents compile-angel from compiling your init
  ;; files. If you choose to remove this and compile your pre/post-init
  ;; files, ensure you understand the implications and thoroughly test your
  ;; code. For example, if you're using the `use-package' macro, you'll need
  ;; to explicitly add: (eval-when-compile (require 'use-package)) at the top
  ;; of your init file.
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes)
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)
  ;; A global mode that compiles .el files when they are loaded
  ;; using `load' or `require'.
  (compile-angel-on-load-mode -1)
  (compile-angel-on-save-mode -1))



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(tsdh-light))
 '(custom-safe-themes
   '("1781e8bccbd8869472c09b744899ff4174d23e4f7517b8a6c721100288311fa5"
     "e7820b899036ae7e966dcaaec29fd6b87aef253748b7de09e74fdc54407a7a02"
     "de8f2d8b64627535871495d6fe65b7d0070c4a1eb51550ce258cd240ff9394b0"
     "87fa3605a6501f9b90d337ed4d832213155e3a2e36a512984f83e847102a42f4"
     "3613617b9953c22fe46ef2b593a2e5bc79ef3cc88770602e7e569bbd71de113b"
     "e622620e5f31216fd71e492fc1476e1fe7c21b8dc5811bf9e640c4b1fd6cfac1"
     "f4d1b183465f2d29b7a2e9dbe87ccc20598e79738e5d29fc52ec8fb8c576fcfd"
     "dfb1c8b5bfa040b042b4ef660d0aab48ef2e89ee719a1f24a4629a0c5ed769e8"
     "22a0d47fe2e6159e2f15449fcb90bbf2fe1940b185ff143995cc604ead1ea171"
     "3799f9b2e997c7cf7d1a5d9846095c8976bce96852eda40d8bf9248157c2615f"
     "fb232a8ae1311f1b8acecb1f766880d12d7a01b7d8d547e7c09325a074a31237"
     "17570f818a8a3877994453342e3425a3b4fa4b3ebac050b4ecbbee958f1ca133"
     "4990532659bb6a285fee01ede3dfa1b1bdf302c5c3c8de9fad9b6bc63a9252f7"
     "e1df746a4fa8ab920aafb96c39cd0ab0f1bac558eff34532f453bd32c687b9d6"
     "599f72b66933ea8ba6fce3ae9e5e0b4e00311c2cbf01a6f46ac789227803dd96"
     "e8ceeba381ba723b59a9abc4961f41583112fc7dc0e886d9fc36fa1dc37b4079"
     "f253a920e076213277eb4cbbdf3ef2062e018016018a941df6931b995c6ff6f6"
     "f053f92735d6d238461da8512b9c071a5ce3b9d972501f7a5e6682a90bf29725"
     "8d3ef5ff6273f2a552152c7febc40eabca26bae05bd12bc85062e2dc224cde9a"
     "2d2bdc418a7811a9652729894b3b74679bd8652959e09f1e046081d722d1987e"
     "f64189544da6f16bab285747d04a92bd57c7e7813d8c24c30f382f087d460a33"
     "cab317d0125d7aab145bc7ee03a1e16804d5abdfa2aa8738198ac30dc5f7b569"
     "39dd7106e6387e0c45dfce8ed44351078f6acd29a345d8b22e7b8e54ac25bac4"
     "f2f7fbafdb70d61c6018a6d902b0f1420400da4d25397a79d0096b36d5a79307"
     "8840f1e732cfd28309a3f35ccdcc9948df3c5e434c3dc8cda8a39ed7c43cfe83"
     "6bdac64e63054091f250439eede14920055c25391c139b8e3cf71cac9ead7d71"
     "8ca212d6ef076ad444f44bf6e57a9841930cbeb0c3f7d7525a21e20a57a3d7f6"
     "4c92d278dc295b63daf817d668523d442058d6c90728958dc92b6bc976fffd96"
     "2ab8cb6d21d3aa5b821fa638c118892049796d693d1e6cd88cb0d3d7c3ed07fc"
     "b7a09eb77a1e9b98cafba8ef1bd58871f91958538f6671b22976ea38c2580755"
     "5c7720c63b729140ed88cf35413f36c728ab7c70f8cd8422d9ee1cedeb618de5"
     "a9eeab09d61fef94084a95f82557e147d9630fbbb82a837f971f83e66e21e5ad"
     "088cd6f894494ac3d4ff67b794467c2aa1e3713453805b93a8bcb2d72a0d1b53"
     "38b43b865e2be4fe80a53d945218318d0075c5e01ddf102e9bec6e90d57e2134"
     "c3c135e69890de6a85ebf791017d458d3deb3954f81dcb7ac8c430e1620bb0f1"
     "c9d837f562685309358d8dc7fccb371ed507c0ae19cf3c9ae67875db0c038632"
     "70c88c01b0b5fde9ecf3bb23d542acba45bb4c5ae0c1330b965def2b6ce6fac3"
     "93011fe35859772a6766df8a4be817add8bfe105246173206478a0706f88b33d"
     "7ec8fd456c0c117c99e3a3b16aaf09ed3fb91879f6601b1ea0eeaee9c6def5d9"
     "9e5e0ff3a81344c9b1e6bfc9b3dcf9b96d5ec6a60d8de6d4c762ee9e2121dfb2"
     "e14289199861a5db890065fdc5f3d3c22c5bac607e0dbce7f35ce60e6b55fc52"
     "bc877ca134b38b7445bbab8526b97bfb7538ba082dd18cf5911f4fe634d21c63"
     "0d2c5679b6d087686dcfd4d7e57ed8e8aedcccc7f1a478cd69704c02e4ee36fe"
     "d481904809c509641a1a1f1b1eb80b94c58c210145effc2631c1a7f2e4a2fdf4"
     "fc3e49bdacf0be94db17e480803d4a59d2ea6501d28ac4183b89085a136033bd"
     "d12b1d9b0498280f60e5ec92e5ecec4b5db5370d05e787bc7cc49eae6fb07bc0"
     "df6dfd55673f40364b1970440f0b0cb8ba7149282cf415b81aaad2d98b0f0290"
     "dd4582661a1c6b865a33b89312c97a13a3885dc95992e2e5fc57456b4c545176"
     "f1e8339b04aef8f145dd4782d03499d9d716fdc0361319411ac2efc603249326"
     "02d422e5b99f54bd4516d4157060b874d14552fe613ea7047c4a5cfa1288cf4f"
     "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098"
     "13096a9a6e75c7330c1bc500f30a8f4407bd618431c94aeab55c9855731a95e1"
     "456697e914823ee45365b843c89fbc79191fdbaff471b29aad9dcbe0ee1d5641"
     "83550d0386203f010fa42ad1af064a766cfec06fc2f42eb4f2d89ab646f3ac01"
     "5244ba0273a952a536e07abaad1fdf7c90d7ebb3647f36269c23bfd1cf20b0b8"
     "9b9d7a851a8e26f294e778e02c8df25c8a3b15170e6f9fd6965ac5f2544ef2a9"
     "7de64ff2bb2f94d7679a7e9019e23c3bf1a6a04ba54341c36e7cf2d2e56e2bcc"
     "02ebb26b9dfabbd0f91fdeb6855e6d7d9dce54ec55e3079c777b25cc758ce082"
     "ca1b398ceb1b61709197478dc7f705b8337a0a9631e399948e643520c5557382"
     "166a2faa9dc5b5b3359f7a31a09127ebf7a7926562710367086fcc8fc72145da"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     "fffef514346b2a43900e1c7ea2bc7d84cbdd4aa66c1b51946aade4b8d343b55a"
     "6963de2ec3f8313bb95505f96bf0cf2025e7b07cefdb93e3d2e348720d401425"
     "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0"
     "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d"
     "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19"
     "720838034f1dd3b3da66f6bd4d053ee67c93a747b219d1c546c41c4e425daf93"
     "a5c590aeb7dc5c2b8d36601a4c94a1145e46bd2291571af02807dd7a8552630c" default))
 '(package-selected-packages
   '(ace-window async auctex bui cfrs compile-angel consult cuda-mode dired-sidebar
		dired-subtree doom-modeline eglot-java elfeed-tube-mpv ewm
		flycheck-eglot flyspell-correct geiser-guile ghostel
		hide-mode-line ht load-relative loc-changes matlab-mode mpvi
		msgpack nerd-icons-dired nov orderless ox-pandoc pandoc
		pandoc-mode pdf-tools perspective pfuture popup posframe ssh
		system-packages test-simple tramp vertico yaml yasnippet))
 '(package-vc-selected-packages nil)
 '(recentf-max-saved-items 33)
 '(warning-suppress-types
   '((files missing-lexbind-cookie
	    "/usr/share/emacs/site-lisp/suse-start-po-mode.el")
     (defvaralias) (lexical))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
