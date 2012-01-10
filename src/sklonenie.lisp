(in-package #:eshop)


(defparameter *group-skls* (make-hash-table :test #'equal))

;; function getNameCountIndex(count) {
;; 	var cnt = (count % 100);
;; 	var result = 0;
;;         if (cnt >= 20) {
;; 	   cnt = (cnt % 10);
;; 	};
;; 	if (cnt == 0) {
;; 	   result = 2;
;; 	} else {
;; 	    if (cnt == 1) {
;; 	   	result = 0;
;; 	    } else {
;;                 if (cnt < 5) {
;; 	           result = 1;
;;                 }  else {
;; 	           result = 2;
;; 		};
;;             };
;; 	};
;; 	return result;
;; }


(defun skls.get-count-skls(count)
  (let ((cnt (mod count 100))
        (result 0))
    (if (>= cnt 20)
        (setf cnt (mod cnt 20)))
    (if (= cnt 0)
        (setf result 2)
        (if (= cnt 1)
            (setf result 0)
            (if (< cnt 5)
                (setf result 1)
                (setf result 2))))
    result))
  ;; 	var cnt = (count % 100);
;; 	var result = 0;
;;         if (cnt >= 20) {
;; 	   cnt = (cnt % 10);
;; 	};
;; 	if (cnt == 0) {
;; 	   result = 2;
;; 	} else {
;; 	    if (cnt == 1) {
;; 	   	result = 0;
;; 	    } else {
;;                 if (cnt < 5) {
;; 	           result = 1;
;;                 }  else {
;; 	           result = 2;
;; 		};
;;             };
;; 	};
;; 	return result;


(defun restore-skls-from-files ()
  (let ((t-storage))
      (print "start load skls....{")
      ;;(sb-ext:gc :full t)
      (let ((*group-skls* (make-hash-table :test #'equal)))
        (load-sklonenie)
        (print *group-skls*)
        (setf t-storage  *group-skls*))
      (setf *group-skls* t-storage)
      ;;(sb-ext:gc :full t)
      (print "...} finish load skls")))

(defun load-sklonenie ()
  (let ((proc (sb-ext:run-program
               "/usr/bin/xls2csv"
               (list "-q3" (format nil "~a/seo/~a" *path-to-dropbox* "sklonenija.xls")) :wait nil :output :stream)))
    (with-open-stream (stream (sb-ext:process-output proc))
      (loop
         :for line = (read-line stream nil)
         :until (or (null line)
                    (string= "" (string-trim "#\," line)))
         :do (let* ((words (sklonenie-get-words line))
                    (skls (mapcar #'(lambda (w) (string-trim "#\""  w))
                             words))
                    (key (string-downcase (car skls))))
               (format t "~&~a" line)
               (setf (gethash key *group-skls*) skls)
               ;; (format t "~&~a: ~{~a~^,~}" key skls)
               )
              ))))

(defmethod sklonenie-get-words ((isg string))
  (let ((bin))
    (values
     (mapcar #'(lambda (y) (string-trim '(#\Space #\Tab) y))
             (mapcar #'(lambda (y) (regex-replace-all "\\s+" y " "))
                     (mapcar #'(lambda (y) (string-trim '(#\Space #\Tab #\") y))
                             (let ((inp) (sv) (ac) (rs))
                               (loop :for cr :across isg do
                                  (if (null inp)
                                      (cond ((equal #\" cr) (setf inp t))
                                            ((equal #\, cr) (push "" rs)))
                                      (cond ((and (null sv) (equal #\" cr)) (setf sv t))
                                            ((and sv (equal #\" cr)) (progn (setf sv nil)
                                                                            (push #\" ac)))
                                            ((and sv (equal #\, cr)) (progn (setf sv nil)
                                                                            (setf inp nil)
                                                                            (push (coerce (reverse ac) 'string) rs)
                                                                            (setf ac nil)))
                                            ((equal #\Return cr) nil)
                                            (t (push cr ac)))))
                               (when ac
                                 (if (and inp (null sv))
                                     (setf bin t))
                                 (push (coerce (reverse ac) 'string) rs))
                               (reverse rs)))))
     bin)))

(defun sklonenie (name skl)
  (let* ((key (string-downcase name))
         (words (gethash key *group-skls*)))
    (if (null words)
        key
        (nth (- skl 1) words))))
