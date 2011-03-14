package head;

import java.util.concurrent.atomic.AtomicInteger;

public class DataProtocol {

	private static final String HOSTNAME = "HOSTNAME";
	private static final String HOST_ACCEPTED = "HOSTACCEPTED";
	private static final int WAITING = 0;
	private static final int WAITING_FOR_HOSTNAME = 1;
	private static final int WAITING_FOR_DATA_HEADER = 1;
	private AtomicInteger state;
	private ClientManager clientManager = null;
	private ClientConnection clientConnection = null;
	private String hostname;

	public DataProtocol(ClientManager manager, ClientConnection c) {
		state = new AtomicInteger(WAITING);
		this.clientManager = manager;
		this.clientConnection = c;
	}

	public String processInput(String theInput) {
		String theOutput = null;
		if (state.get() == WAITING) {
			theOutput = HOSTNAME;
			state.set(WAITING_FOR_HOSTNAME);
		} else if (state.get() == WAITING_FOR_HOSTNAME) {
			// add the client to the client manager
			hostname = theInput;
			clientManager.addClient(hostname, clientConnection);
			theOutput = HOST_ACCEPTED;
			state.set(WAITING_FOR_DATA_HEADER);
		}else if(state.get() == WAITING_FOR_DATA_HEADER){
			//get the data header from the client and begin parsing of the data
		}
		return theOutput;
	}

	public void setState(int STATE) {
		this.state.set(STATE);
	}
}