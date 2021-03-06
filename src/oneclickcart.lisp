(in-package #:eshop)

 ;;обновление страницы
 (defun oneclickcart-update ()
   (mapcar #'(lambda (fname)
               (let ((pathname (pathname (format nil "~a/~a" *path-to-tpls* fname))))
                 (closure-template:compile-template :common-lisp-backend pathname)))
           '("oneclickcart.soy"
             "buttons.soy")))



(defun oneclick-sendmail (phone articul name email)
  (let ((client-mail)
        (mail-file)
        (filename)
        (tks-mail)
        (order-id (get-order-id))
        (count)
        (pricesum)
        (products)
        (cart (list (list (cons :id articul) (cons :count 1)))))
    (multiple-value-bind (lst cnt sm) (newcart-cart-products cart)
      (setf products (remove-if #'null lst))
       ;; (print products)
      (setf count cnt)
      (setf pricesum sm))
    (setf client-mail
          (sendmail:clientmail-elka
           (list :datetime (time.get-date-time)
                 :order_id order-id
                 :name (report.convert-name name)
                 :family "" ;; Фамилия не передается отдельно
                 :paytype "Наличными"
                 :deliverytype "Самовывоз"
                 :addr "Левашовский пр., д.12"
                 :bankaccount ""
                 :phone phone
                 :email email
                 :comment (format nil "Заказ с новогодней елки.")
                 :products products
                 :deliverysum 0
                 :itogo pricesum)))
    (setf mail-file
          (list :order_id order-id
                :ekk ""
                :name (report.convert-name name)
                :family ""
                :addr "Левашовский пр., д.12"
                :phone phone
                :email email
                :isdelivery "Самовывоз"
                :date (time.get-date)
                :time (time.get-time)
                :comment (format nil "Заказ с новогодней елки.")
                :products products))
    (setf filename (format nil "~a_~a.txt" (time.get-short-date) order-id))
    ;;сорханение заказа
    (save-order-text order-id client-mail)
    ;; удаление страных символов
    (setf client-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) client-mail))
    (setf tks-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) (sendmail:mailfile mail-file)))
    (mapcar #'(lambda (email)
                (send-mail (list email) client-mail filename tks-mail order-id))
            *conf.emails.cart*)
    (if (not (string= email ""))
        (send-client-mail (list email) client-mail order-id))
    order-id))


(defun oneclick-sendmail1 (phone articul name email)
  (let ((client-mail)
        (mail-file)
        (filename)
        (tks-mail)
        (order-id (get-order-id))
        (count)
        (pricesum)
        (products)
        (cart (list (list (cons :id articul) (cons :count 1)))))
    (multiple-value-bind (lst cnt sm) (newcart-cart-products cart)
      (setf products (remove-if #'null lst))
       ;; (print products)
      (setf count cnt)
      (setf pricesum sm))
    (setf client-mail
          (sendmail:clientmail
           (list :datetime (time.get-date-time)
                 :order_id order-id
                 :name (report.convert-name name)
                 :family "" ;; Фамилия не передается отдельно
                 :paytype "Наличными"
                 :deliverytype "Самовывоз"
                 :addr "Левашовский пр., д.12"
                 :bankaccount ""
                 :phone phone
                 :email email
                 :comment (format nil "Заказ через форму один клик ~@[!!! Предзаказ !!!~]" (preorder (gethash articul (storage *global-storage*))))
                 :products products
                 :deliverysum 0
                 :itogo pricesum)))
    (setf mail-file
          (list :order_id order-id
                :ekk ""
                :name (report.convert-name name)
                :family ""
                :addr "Левашовский пр., д.12"
                :phone phone
                :email email
                :isdelivery "Самовывоз"
                :date (time.get-date)
                :time (time.get-time)
                :comment (format nil "Заказ через форму один клик ~@[!!! Предзаказ !!!~]" (preorder (gethash articul (storage *global-storage*))))
                :products products))
    (setf filename (format nil "~a_~a.txt" (time.get-short-date) order-id))
            ;;сорханение заказа
    (save-order-text order-id client-mail)
    ;; удаление страных символов
    (setf client-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) client-mail))
    (setf tks-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) (sendmail:mailfile mail-file)))
    (mapcar #'(lambda (email)
                (send-mail (list email) client-mail filename tks-mail order-id))
            *conf.emails.cart*)
    (if (not (string= email ""))
        (send-client-mail (list email) client-mail order-id))
    order-id))


(defun oneclickcart-page (request-get-plist)
  (let ((telef (getf request-get-plist :telef))
        (name (getf request-get-plist :name))
        (articul (getf request-get-plist :articul))
        (email (getf request-get-plist :email))
        (order-id))
   (if (not (null telef))
       (progn
         (setf order-id (oneclick-sendmail telef articul name email))
         (soy.oneclickcart:answerwindow (list :phone telef
                                              :orderid order-id)))
       (soy.oneclickcart:formwindow (list :articul articul)))))


(defun oneclick-sendmail2 (phone articul name email)
  (let ((client-mail)
        (mail-file)
        (filename)
        (tks-mail)
        (order-id (get-order-id))
        (count)
        (pricesum)
        (products)
        (cart (list (list (cons :id articul) (cons :count 1)))))
    (setf client-mail
          (sendmail:clientmail
           (list :datetime (time.get-date-time)
                 :order_id order-id
                 :name (report.convert-name name)
                 :family "" ;; Фамилия не передается отдельно
                 :paytype "Наличными"
                 :deliverytype "Самовывоз"
                 :addr "Левашовский пр., д.12"
                 :bankaccount ""
                 :phone phone
                 :email email
                 :comment "Предзаказ на ультрабук"
                 :products nil
                 :deliverysum 0
                 :itogo 0)))
    (setf mail-file
          (list :order_id order-id
                :ekk ""
                :name (report.convert-name name)
                :family ""
                :addr "Левашовский пр., д.12"
                :phone phone
                :email email
                :isdelivery "Самовывоз"
                :date (time.get-date)
                :time (time.get-time)
                :comment "Предзаказ на ультрабук"
                :products nil))
    (setf filename (format nil "~a_~a.txt" (time.get-short-date) order-id))
            ;;сорханение заказа
    (save-order-text order-id client-mail)
    ;; удаление страных символов
    (setf client-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) client-mail))
    (setf tks-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) (sendmail:mailfile mail-file)))
    (mapcar #'(lambda (email)
                (send-mail (list email) client-mail filename tks-mail order-id))
            *conf.emails.cart*)
    (if (not (string= email ""))
        (send-client-mail (list email) client-mail order-id))
    order-id))


(defun oneclick-sendmail3 (phone articul name email)
  (let ((client-mail)
        (mail-file)
        (filename)
        (tks-mail)
        (order-id (get-order-id))
        (count)
        (pricesum)
        (products)
        (cart (list (list (cons :id articul) (cons :count 1)))))
    (setf client-mail
          (sendmail:clientmail
           (list :datetime (time.get-date-time)
                 :order_id order-id
                 :name (report.convert-name name)
                 :family "" ;; Фамилия не передается отдельно
                 :paytype "Наличными"
                 :deliverytype "Самовывоз"
                 :addr "Левашовский пр., д.12"
                 :bankaccount ""
                 :phone phone
                 :email email
                 :comment "Предзаказ на Nikon D4"
                 :products nil
                 :deliverysum 0
                 :itogo 0)))
    (setf mail-file
          (list :order_id order-id
                :ekk ""
                :name (report.convert-name name)
                :family ""
                :addr "Левашовский пр., д.12"
                :phone phone
                :email email
                :isdelivery "Самовывоз"
                :date (time.get-date)
                :time (time.get-time)
                :comment "Предзаказ на Nikon D4"
                :products nil))
    (setf filename (format nil "~a_~a.txt" (time.get-short-date) order-id))
            ;;сорханение заказа
    (save-order-text order-id client-mail)
    ;; удаление страных символов
    (setf client-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) client-mail))
    (setf tks-mail (remove-if #'(lambda(c) (< 10000 (char-code c))) (sendmail:mailfile mail-file)))
    (mapcar #'(lambda (email)
                (send-mail (list email) client-mail filename tks-mail order-id))
            *conf.emails.cart*)
    (if (not (string= email ""))
        (send-client-mail (list email) client-mail order-id))
    order-id))



(defun oneclickcart.page (request-get-plist)
  (let ((telef (getf request-get-plist :telef))
        (name (getf request-get-plist :name))
        (articul (getf request-get-plist :articul))
        (email (getf request-get-plist :email))
        (order-id))
   (if (not (null telef))
       (progn
         (if (equal "/elka2012"
                    (puri:uri-path (puri:parse-uri (hunchentoot:referer))))
             (setf order-id (oneclick-sendmail telef articul name email))
             (if (equal "33" articul)
                 (setf order-id (oneclick-sendmail2 telef articul name email))
                 (if (equal "34" articul)
                     (setf order-id (oneclick-sendmail3 telef articul name email))
                     (setf order-id (oneclick-sendmail1 telef articul name email)))))
         (soy.oneclickcart:answerwindow (list :phone telef
                                              :orderid order-id)))
       (soy.oneclickcart:formwindow1 (list :articul articul)))))
