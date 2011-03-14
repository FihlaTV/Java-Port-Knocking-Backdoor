package plugins;

import java.io.PrintWriter;

import util.CommandController;

public interface Command {
	
	/**
	 * The method that will be called to perform the action of the command
	 * @param  input the original command that was inputed
	 */
	public void doAction(String input, PrintWriter out, CommandController cc);	

	/**
	 * This method is used to add the command to the Map of commands
	 * 
	 * @return the string command
	 */
	public String getCommand();

	/**
	 * This method will be called when the command help &#060;command&#062; is issued
	 * @return the string command
	 */
	public String getHelp();


}