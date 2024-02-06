import RPi.GPIO as GPIO
import time
import assembler

def setup_GPIO():
	GPIO.setmode(GPIO.BCM)
	GPIO.setwarnings(True)
	
	# Reset Signal Output
	GPIO.setup(5, GPIO.OUT)

	# Instruction Output
	GPIO.setup(21, GPIO.OUT) # instruction[0]
	GPIO.setup(20, GPIO.OUT) # instruction[1]
	GPIO.setup(16, GPIO.OUT) # instruction[2]
	GPIO.setup(12, GPIO.OUT) # instruction[3]
	GPIO.setup(1,  GPIO.OUT) # instruction[4]
	GPIO.setup(7,  GPIO.OUT) # instruction[5]
	GPIO.setup(8,  GPIO.OUT) # instruction[6]
	GPIO.setup(25, GPIO.OUT) # instruction[7]
	
	# Instruction Address Input
	GPIO.setup(24, GPIO.IN)  # instruction_address[0]
	GPIO.setup(23, GPIO.IN)  # instruction_address[1]
	GPIO.setup(18, GPIO.IN)  # instruction_address[2]
	GPIO.setup(15, GPIO.IN)  # instruction_address[3]
	GPIO.setup(14, GPIO.IN)  # instruction_address[4]
	GPIO.setup(26, GPIO.IN)  # instruction_address[5]
	GPIO.setup(19, GPIO.IN)  # instruction_address[6]
	GPIO.setup(13, GPIO.IN)  # instruction_address[7]
	
	# Address Receive Signal
	GPIO.setup(6, GPIO.IN)
	# Instruction Transmit Signal
	GPIO.setup(11, GPIO.OUT)
	
def write_instruction(instruction: int):
	GPIO.output(21, (instruction >> 0) & 1)
	GPIO.output(20, (instruction >> 1) & 1)
	GPIO.output(16, (instruction >> 2) & 1)
	GPIO.output(12, (instruction >> 3) & 1)
	GPIO.output(1,  (instruction >> 4) & 1)
	GPIO.output(7,  (instruction >> 5) & 1)
	GPIO.output(8,  (instruction >> 6) & 1)
	GPIO.output(25, (instruction >> 7) & 1)
	
def read_instruction_addr() -> int:
	a0 = GPIO.input(24) << 0;
	a1 = GPIO.input(23) << 1;
	a2 = GPIO.input(18) << 2;
	a3 = GPIO.input(15) << 3;
	a4 = GPIO.input(14) << 4;
	a5 = GPIO.input(26) << 5;
	a6 = GPIO.input(19) << 6;
	a7 = GPIO.input(13) << 7;
	
	return a7 | a6 | a5 | a4 | a3 | a2 | a1 | a0
	
def read_address_receive_signal() -> int:
	return GPIO.input(6)
	
def wait_for_receive_posedge_with_timeout():
	counter = 0
	while not read_address_receive_signal():
		if counter == 50: # randomize timeout
			return -1
		counter += 1
	return 0
		
def wait_for_receive_negedge_with_timeout():
	counter = 0
	while read_address_receive_signal():
		if counter == 50:
			return -1
		counter += 1
	return 0
	
def wait_for_receive_posedge():
	while not read_address_receive_signal():
		pass
		
def wait_for_receive_negedge():
	while read_address_receive_signal():
		pass
	
def enable_instruction_transmit_signal():
	GPIO.output(11, 1)
	
def disable_instruction_transmit_signal():
	GPIO.output(11, 0)
	
def reset():
	while True:
		GPIO.output(5, 1)
		if (wait_for_receive_posedge_with_timeout() == -1):
			GPIO.output(5, 0)
			continue
		GPIO.output(5, 0)
		if (wait_for_receive_negedge_with_timeout() == -1):
			continue
		break
		
	return 0
	
def main():
	setup_GPIO()

	instruction_memory = assembler.assemble("heat.asm")
		
	# Reset all states to zero
	reset()
	
	while True:
		try:
			while True:
				# Wait until a positive edge occurs in receive signal
				if wait_for_receive_posedge_with_timeout() == -1:
					continue
				
				# Get address, fetch instruction and send it to the device
				addr = read_instruction_addr()
				write_instruction(instruction_memory[addr])
				
				# Print address and the instruction
				# print(addr, instruction_memory[addr])
				
				# Let the device know that the information is ready
				enable_instruction_transmit_signal()
			
				# Wait until negative edge occurs in address receive signal
				if wait_for_receive_negedge_with_timeout() == -1:
					disable_instruction_transmit_signal()
					continue
					
				# Now, it is known that the device has received the instruction.
				# Let the device know that the transmission has completed.
				disable_instruction_transmit_signal()
				break
			
		except KeyboardInterrupt:
			break
		
	reset()
	GPIO.cleanup()
	
	print("Total microseconds:", (end-start)*10**6)

if __name__ == "__main__":
	main()
