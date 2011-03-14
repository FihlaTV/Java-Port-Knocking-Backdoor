package packet;

import java.io.Serializable;

public class Packet implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 7303165012788620591L;
	
	private boolean giveBackAllData;
	private boolean sendingAllData;
	private int totalRowLength;
	private int totalColumnLength;
	private int rowMin;
	private int rowMax;
	private int columnMin;
	private int columnMax;
	private long[][] data;
	private long[] westEdgeData;
	private long[] eastEdgeData;
	private final double[] metalConstants;
	private final int[][][] percentageOfMetals;
	
	public Packet(boolean giveBackAllData, int rowMin, int rowMax, int columnMin, int columnMax, long[] eastEdgeData, long[] westEdgeData){
		this.sendingAllData = false;
		this.giveBackAllData = giveBackAllData;
		this.eastEdgeData = eastEdgeData;
		this.westEdgeData = westEdgeData;
		this.rowMin = rowMin;
		this.rowMax = rowMax;
		this.columnMin = columnMin;
		this.columnMax = columnMax;
		this.percentageOfMetals = null;
		this.metalConstants = null;
		this.data = null;
	}

	public Packet(int totalRowLength, int totalColumnLength,
			int rowMin, int rowMax, int columnMin, int columnMax, long[][] data, long[] eastEdgeData,
			long[] westEdgeData, double[] metalConstants, int[][][] percentageOfMetals) {
		this.giveBackAllData = true;
		//this.sendingAllData = sendingAllData;
		this.sendingAllData = true;
		this.totalRowLength = totalRowLength;
		this.totalColumnLength = totalColumnLength;
		this.rowMin = rowMin;
		this.rowMax = rowMax;
		this.columnMin = columnMin;
		this.columnMax = columnMax;
		this.data = data;
		this.westEdgeData = westEdgeData;
		this.eastEdgeData = eastEdgeData;
		this.metalConstants = metalConstants;
		this.percentageOfMetals = percentageOfMetals;
	}

	/**
	 * @return the westEdgeData
	 */
	public long[] getWestEdgeData() {
		return westEdgeData;
	}

	/**
	 * @param westEdgeData
	 *            the westEdgeData to set
	 */
	public void setWestEdgeData(long[] westEdgeData) {
		this.westEdgeData = westEdgeData;
	}

	/**
	 * @return the eastEdgeData
	 */
	public long[] getEastEdgeData() {
		return eastEdgeData;
	}

	/**
	 * @param eastEdgeData
	 *            the eastEdgeData to set
	 */
	public void setEastEdgeData(long[] eastEdgeData) {
		this.eastEdgeData = eastEdgeData;
	}

	/**
	 * @return the giveBackAllData
	 */
	public boolean isGiveBackAllData() {
		return giveBackAllData;
	}

	/**
	 * @param giveBackAllData
	 *            the giveBackAllData to set
	 */
	public void setGiveBackAllData(boolean giveBackAllData) {
		this.giveBackAllData = giveBackAllData;
	}

	/**
	 * @return the sendingAllData
	 */
	public boolean isSendingAllData() {
		return sendingAllData;
	}

	/**
	 * @param sendingAllData
	 *            the sendingAllData to set
	 */
	public void setSendingAllData(boolean sendingAllData) {
		this.sendingAllData = sendingAllData;
	}

	/**
	 * @return the rowMin
	 */
	public int getRowMin() {
		return rowMin;
	}

	/**
	 * @param rowMin
	 *            the rowMin to set
	 */
	public void setRowMin(int rowMin) {
		this.rowMin = rowMin;
	}

	/**
	 * @return the rowMax
	 */
	public int getRowMax() {
		return rowMax;
	}

	/**
	 * @param rowMax
	 *            the rowMax to set
	 */
	public void setRowMax(int rowMax) {
		this.rowMax = rowMax;
	}

	/**
	 * @return the columnMin
	 */
	public int getColumnMin() {
		return columnMin;
	}

	/**
	 * @param columnMin
	 *            the columnMin to set
	 */
	public void setColumnMin(int columnMin) {
		this.columnMin = columnMin;
	}

	/**
	 * @return the columnMax
	 */
	public int getColumnMax() {
		return columnMax;
	}

	/**
	 * @param columnMax
	 *            the columnMax to set
	 */
	public void setColumnMax(int columnMax) {
		this.columnMax = columnMax;
	}

	/**
	 * @param data
	 *            the data to set
	 */
	public void setData(long[][] data) {
		this.data = data;
	}

	/**
	 * @return the data
	 */
	public long[][] getData() {
		return data;
	}

	/**
	 * @return the metalConstants
	 */
	public double[] getMetalConstants() {
		return metalConstants;
	}

	/**
	 * @return the percentageOfMetals
	 */
	public int[][][] getPercentageOfMetals() {
		return percentageOfMetals;
	}

	/**
	 * @return the totalRowLength
	 */
	public int getTotalRowLength() {
		return totalRowLength;
	}

	/**
	 * @param totalRowLength
	 *            the totalRowLength to set
	 */
	public void setTotalRowLength(int totalRowLength) {
		this.totalRowLength = totalRowLength;
	}

	/**
	 * @return the totalColumnLength
	 */
	public int getTotalColumnLength() {
		return totalColumnLength;
	}

	/**
	 * @param totalColumnLength
	 *            the totalColumnLength to set
	 */
	public void setTotalColumnLength(int totalColumnLength) {
		this.totalColumnLength = totalColumnLength;
	}
}