import socket
class Account:
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
			menu()

	def getslaves ():
		if loggedin == 1:
			s.send('GETSLAVES\n')
			data = s.recv(1000000)
			print data
		else:
			print 'Failed. Are you sure you are logged in?'
			menu()

	def loginslave ():
		if loggedin == 1:
			slaveip = raw_input("Insert the IP you want to log in to: ")
			s.send('LOGINSLAVE ' + slaveip + '\n')
			data = s.recv(1000000)
			if data == 1:
				clearslavelogs()
				slavemenu()
			else:
				print "Failed. Either this is not a valid IP, or it is not yet a slave of yours. Try cracking the IP first, or check if you've enterred the right IP."
		else:
			print 'Failed. Are you sure you are logged in?'
			menu ()
	def clearslavelogs ():
		if loggedin == 1:
			if ip == 0:
				print "You are not logged in to an IP."
				menu()
			else:
				s.send('CLEAR_LOGS_IP ' + myip + '\n')
				data = s.recv(1000000)
				if data == 1:
					print "Log-clear succeeded"
					slavemenu()
				else:
					print "Log-clear failed."
					slavemenu()
		else:
			print 'Failed. Are you sure you are logged in?'
			menu()
	def crackip ():
		if loggedin == 1:
			crackip = raw_input("Inser the IP you want to crack: ")
			s.send('CRACKIP ' + crackip + '\n')
			data = s.recv(1000000)
			if data == 1:
				print 'Crack succeeded. Logging in.'
				cloginslave(crackip)
			elif data == 0:
				print 'Crack failed. Would you like to retry?
				print '1 - Yes.'
				print '2 - No.'
				choice = input("Please choose: "
				if choice = 1:
					rcrackip(crackip)
				elif choice = 2:
					menu()
			else:
				print 'Failed. Something may have screwed up.'
				menu()
		else:
			'Failed. Are you sure you are logged in?'
			menu()
	def rcrackip (newslaveip):
		s.send('CRACKIP ' + slaveip + '\n')
		data = s.recv(1000000)
		if data == 1:
			print 'Crack succeeded. Logging in.'
			cloginslave(crackip)
		elif data == 0:
			print "Crack failed. Would you like to retry?
			choice = input("Please choose: "
			if choice = 1:
				rcrackip(crackip)
			elif choice = 2:
				menu()
		else:
			print 'Failed. Something may have screwed up.'
			menu()
	def cloginslave (newslaveip):
		s.send('LOGINSLAVE ' + newslaveip + '\n')
		data = s.recv(1000000)
		if data == 1:
			print 'Login succeeded.'
			ip = newslaveip
			slavemenu()
		else:
			print 'Failed.'
			menu()
		
	def slavemenu ():
		if loggedin == 1:
			if ip == 0:
				print "You are not logged in to an IP."
				menu()
			else:
				print "You are connected to: " + ip
				print "Please select the number corresponding to the action you want to do."
				print "1 - Clear your IP from a slave's log."
				print "2 - Log out of Slave."
				schoice = input("Please choose: ")
				if schoice == 1:
					clearslavelogs()
				if schoice == 2:
					menu()
				
		else:
			print "Failed to generate Slave-menu. Are you sure you are logged in?"
			menu()
	def menu ():
		print "This is the main menu."
		print "1 - Log in to your account."
		print "2 - Clear local logs."
		print "3 - Get Slaves."
		print "4 - Connect to an IP."
		print "5 - Crack an IP."

		choice = input('Please select one of the above: ')
		if choice == 1:
			login()
		elif choice == 2:
			clearlocallogs()
		elif choice == 3:
			getslaves()
		elif choice == 4:
			loginslave()
		elif choice == 5:
			crackip()
		else:
			print 'Invalid option'
			menu()
host = 'localhost'
port = 9988

loggedin = 0
slaveip = 0

print 'Creating socket...'
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
print 'Done.'
print 'Connecting to TCP server...'
s.connect((host, port))
print 'Done.'

account1 = Account()
account1.menu
