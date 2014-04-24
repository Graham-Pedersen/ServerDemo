(using System.Net)
(using System)
(using System.Net.Sockets)
;(using "C:\\Users\\graha_000\\Documents\\Visual Studio 2012\\Projects\\Reader\\Reader\\bin\\Debug\\Reader.dll" Reader)
(using "C:\\Users\\graha_000\\Documents\\Visual Studio 2012\\Projects\\DemoRepo\\Reader\\Reader\\bin\\Debug\\Reader.dll" Reader)

(define list "System.Collections.Generic.List")

(define do_setup (lambda ()
	(define ipHostInfo
			(scall 
				System.Net.Dns 
				GetHostEntry
				(scall System.Net.Dns GetHostName)))
	(define ip 
		(call 
			(new list 
				(typelist System.Net.IPAddress)
				(call ipHostInfo AddressList))
			Item
			0))
	(define port 11000)
	(displayln  (cons '(starting on) (cons ip (cons '(and port) (cons port '())))))
	(define family (call ip AddressFamily))
	(define stype (scall SocketType Stream))
	(define protocol (scall System.Net.Sockets.ProtocolType Tcp))
	(define endpoint (new System.Net.IPEndPoint ip port))
	(define server_sock (new Socket family stype protocol))
	(call server_sock Bind endpoint)
	(call server_sock Blocking set #f)
	(call server_sock Listen 10)
	(displayln "server started...")
	server_sock))

(define (encode str)
	(define enc (scall System.Text.Encoding UTF8))
	(call enc GetBytes str))	

(define (decode bytes)
	(define enc (scall System.Text.Encoding UTF8))
	(call enc GetString bytes))

(define (send_message sock message) 
	(call sock Send (encode message)))

(define (get_message client) 
	(define count (call client Available))
	(define type (call (typelist System.Byte) resolveType))
	(define bytes (scall 
					Reader
					makeByteArr
					count))
	(call client Receive bytes)
	(displayln (cons 'received (decode bytes)))
	(map 
		(lambda (sock) 
			(send_message	
				sock 
				(scall System.String Format "{0}:      {1}" (call (call (call client RemoteEndPoint) ToString) Substring 0 29) (decode bytes))))
		clist))

(define (listen client)
	(cond
		[(null? client) '()]
		[(and
			(call client Poll 0 (scall System.Net.Sockets.SelectMode SelectRead))
			(not (equal? (call client Available) 0)))
			; =>>>
			(get_message client)]))

(define (cull clist)
	(if (null? clist)
		'()
		(let ([sock (car clist)])
			(if (and 
					(call sock Poll 0 (scall System.Net.Sockets.SelectMode SelectRead))
					(equal? (call sock Available) 0))
				;cull
				(begin
					(displayln "Client Left!")
					(set! leave_list (cons (scall System.String Format "{0} left!" (call (call sock RemoteEndPoint) ToString)) leave_list))
					(cull (cdr clist)))
				(cons sock (cull (cdr clist)))))))
					
	
(define (accept_client server clist) 
		(if (call server Poll 0 (scall System.Net.Sockets.SelectMode SelectRead))
			(begin 
				(define newbie (call server Accept))
				(displayln "Client connected!")
				(map
					(lambda (sock)
						(send_message sock (scall System.String Format "{0} joined!" (call (call newbie RemoteEndPoint) ToString))))
					clist)
				(call newbie Blocking set #f)
				(cons newbie clist))
			clist))

(define (work server_sock)
		(while #t
			(begin
				(set! clist (cull clist))
				(if (not (null? leave_list))
					(begin
						(map
							(lambda (sock)
								(send_message sock (car leave_list)))
							clist)
						(set! leave_list (cdr leave_list)))
						'())
				(map listen clist)
				(set! clist (accept_client server_sock clist)))))

(define clist '())
(define leave_list '())
(define server_sock (do_setup))
(work server_sock)







