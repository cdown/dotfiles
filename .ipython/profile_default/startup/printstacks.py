import faulthandler, signal
faulthandler.register(signal.SIGUSR1)
