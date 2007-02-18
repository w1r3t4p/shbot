import socket

#Settings
clearlogonlogin = 1

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
	else:
		print 'Login Failed!'


def clearlocallogs ():
	s.send('CLEAR_LOCAL_LOGS\n')
	data = s.recv(1000000)
	if data == 1:
		print 'Log-clear succeeded'
		menu()
	else:
		print 'Log-clear failed'
		menu()

def menu():
	print 'Generating Main Menu'
	print "Welcome to the Slave-Hacker!\n"
	print "Please note that this software is still very fucked up, don't expect it to like work anything.\n"
# C'mon, you can write more improfessionaly than that =)
	print "This is the main menu."

	print "1 - Log in to your account."
	print "2 - Clear local logs."
	print "3 - Change Settings"

	choice = raw_input('Please select one of the above: ')
	if choice == 1:
		login()
	elif choice == 2:
		clearlocallogs()
	elif choice == 3:
		changesettings()
	else:
		print 'Invalid option'
		menu()
host = 'localhost'
port = 9988

print 'Creating socket...'
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'Done.'
print 'Connecting to TCP server...'
s.connect((host, port))
print 'Done.'

menu()
