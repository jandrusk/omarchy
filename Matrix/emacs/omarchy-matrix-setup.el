;;; omarchy-matrix-setup.el --- Load the Omarchy Matrix Emacs theme -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Drop-in loader for `omarchy-matrix-theme.el'. Copy the theme into
;; `user-emacs-directory'/themes and require this file from your init,
;; or paste the forms below.

;;; Code:

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

(defun my/load-omarchy-matrix ()
  "Load the Omarchy Matrix theme, disabling other color themes."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'omarchy-matrix t))

(my/load-omarchy-matrix)

(provide 'omarchy-matrix-setup)
;;; omarchy-matrix-setup.el ends here
