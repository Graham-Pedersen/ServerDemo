(using System.Net.Sockets)
(using System.Net)
(using System)
;(using "C:\\Users\\graha_000\\Documents\\Visual Studio 2012\\Projects\\Reader\\Reader\\bin\\Debug\\Reader.dll" Reader)
(using "C:\\Users\\graha_000\\Documents\\Visual Studio 2012\\Projects\\DemoRepo\\Reader\\Reader\\bin\\Debug\\Reader.dll" Reader)

(define do_setup (lambda ()
	(define ipHostInfo
			(scall Dns GetHostEntry
				(scall Dns GetHostName)))
	(displayln "input the ip of the host you want to connect to")
	(define ip (scall System.Net.IPAddress Parse (scall System.Console ReadLine)))
	(define port 11000)
	(displayln  (cons '(connecting) (cons ip (cons '(and port) (cons port '())))))
	(define family (call ip AddressFamily))
	(define stype (scall System.Net.Sockets.SocketType Stream))
	(define protocol (scall System.Net.Sockets.ProtocolType Tcp))
	(define endpoint (new System.Net.IPEndPoint ip port))
	(define sock (new Socket family stype protocol))
	(call sock Connect endpoint)
	(call sock Blocking set #f)
	(displayln "made connection")
	sock))

(define (get_input) 
	(scall Reader ReadLine 100))

(define (encode str)
	(define enc (scall System.Text.Encoding UTF8))
	(call enc GetBytes str))

(define (decode bytes)
	(define enc (scall System.Text.Encoding UTF8))
	(call enc GetString bytes))

(define (send_message sock message) 
	(call sock Send (encode message)))

(define (get_message server) 
	(define count (call server Available))
	(define type (call (typelist System.Byte) resolveType))
	(define bytes (scall 
					Reader
					makeByteArr
					count))
	(call server Receive bytes)
	(displayln (decode bytes)))

(define (check_sock server)
		(if 
			(and
				(call server Poll 0 (scall System.Net.Sockets.SelectMode SelectRead))
				(not (equal? (call server Available) 0)))
			(displayln (get_message server))
			'()))

(define (workloop server)
		(while #t 
			(begin
				(let ([input (get_input)])
					(if (not (equal? "" input))
						(send_message server input)
						'())
				(check_sock server)))))
	
(define server_con (do_setup))
(workloop server_con)
	

	