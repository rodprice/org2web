;;; op-config.el --- Functions dealing with org-page configure

;; Copyright (C)  2015 Feng Shu

;; Author: Feng Shu <tumashu AT 163 DOT com>
;; Keywords: convenience
;; Homepage: https://github.com/tumashu/org-page

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; op-config.el contains functions used to deal with org-page configure.

;;; Code:

(require 'op-vars)

(defun op/get-config-option (option)
  (when (functionp op/get-config-option-function)
    (funcall op/get-config-option-function option)))

(defun op/get-config-option-from-alist (option)
  (let ((project-plist (cdr (assoc op/current-project-name
                                   op/project-config-alist))))
    (if (plist-member project-plist option)
        (plist-get project-plist option)
      (plist-get op/config-fallback option))))

(defun op/get-repository-directory ()
  (let ((dir (op/get-config-option :repository-directory)))
    (when dir
      (expand-file-name dir))))

(defun op/get-site-domain ()
  (let ((site-domain (op/get-config-option :site-domain)))
    (when site-domain
      (if (or (string-prefix-p "http://"  site-domain)
              (string-prefix-p "https://" site-domain))
          site-domain
        (concat "http://" site-domain)))))

(defun op/get-theme-dirs (&optional root-dir theme type)
  "Get org-page theme type path.

org-page organizes its themes by directory:

| Directory           |  Argument   |  Value                 |
+---------------------+-------------+------------------------+
| /path/to/directory  |  <root-dir> | \"/path/to/directory\" |
|  \--mdo             |  <theme>    | 'mdo                   |
|      |-- templates  |  <type>     | 'templates             |
|       \- resources  |  <type>     | 'resources             |

`root-dir' and `theme' can be lists, for example:

  `(\"path/to/dir1\" \"path/to/dir2\" \"path/to/dir3\")'
  `(theme1 theme2 theme3)'

At this time, `op/get-theme-dirs' will find *all possible*
<type> directorys by permutation way and return a list with
multi path."
  (let* ((themes (delete-dups
                  (if theme
                      (list theme)
                    `(,@(op/get-config-option :theme) default))))
         (theme-root-dirs (delete-dups
                           (if root-dir
                               (list root-dir)
                             `(,@(op/get-config-option :theme-root-directory)
                               ,(concat (op/get-repository-directory) "themes/")
                               ,(concat op/load-directory "themes/")))))
         theme-dir theme-dirs)
    (dolist (theme themes)
      (dolist (root-dir theme-root-dirs)
        (setq theme-dir
              (file-name-as-directory
               (expand-file-name
                (format "%s/%s" (symbol-name theme)
                        (if type (symbol-name type) ""))
                root-dir)))
        (when (file-directory-p theme-dir)
          (push theme-dir theme-dirs))))
    (reverse theme-dirs)))

(defun op/get-html-creator-string ()
  (or (op/get-config-option :html-creator-string) ""))

(defun op/get-category-setting (category)
  "Return category config of `category'"
  (or (assoc category op/category-config-alist)
      `(,category
        :show-meta t
        :show-comment t
        :uri-generator op/generate-uri
        :uri-template ,(format "/%s/%%y/%%m/%%d/%%t/" category)
        :sort-by :date
        :category-index t)))

(provide 'op-config)

;;; op-config.el ends here
