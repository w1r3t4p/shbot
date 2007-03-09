import socket
def login ():
	print 'Please enter your login information:'
	login = raw_input('Username:')
	password = raw_input('Password:')
	s.send('LOGIN ' + login + ' ' + password + '\n')
	data = s.recv(10000000)
	print 'Logging in...'
	print data
	if data == 1:
		print 'Login Succeeded!'
		clearlocallogs()
		loggedin = 1
	else:
		print 'Login Failed!'
		menu()

def clearlocallogs ():
	if loggedin == 1:
		s.send('CLEAR_LOCAL_LOGS\n')
		data = s.recv(1000000)
		if data == 1:
			print 'Log-clear succeeded'
			menu()
		else:
			print 'Log-clear failed'
			menu()
	else:
		print 'Failed. Are you sure you are logged in?'

def getslaves ():
	if loggedin == 1:
		s.send('GETSLAVES\n')
		data = s.recv(1000000)
		print data
	else:
		print 'Failed. Are you sure you are logged in?'

def menu ():
	print 'Generating Main Menu'
	print "Welcome to the Slave-Hacker!\n"
	print "Please note that this software is still very fucked up, don't expect it to like work anything.\n"
	print "This is the main menu."

	print "1 - Log in to your account."
	print "2 - Clear local logs."
	print "3 - Get Slaves"

	choice = raw_input('Please select one of the above: ')
	if choice == 1:
		login()
	elif choice == 2:
		clearlocallogs()
	elif choice == 3:
		getslaves()
	else:
		print 'Invalid option'
		menu()
host = 'localhost'
port = 9988

loggedin = 0

print 'Creating socket...'
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'Done.'
print 'Connecting to TCP server...'
s.connect((host, port))
print 'Done.'

menu()
