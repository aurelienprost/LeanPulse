/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.remote.internal;

import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.CancellationException;

import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * An filter input stream that reports progress to a monitor while reading the
 * data and that enables to cancel the reading.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class ProgressInputStream extends FilterInputStream {
	
	IProgressMonitor mon;
	long numBytes;
	
	/**
	 * Creates the progress input stream.
	 * 
	 * @param in
	 *            The underlying input stream.
	 * @param mon
	 *            The progress monitor to which progress is reported and that
	 *            can cancel the reading.
	 * @param numBytes
	 *            The total number of bytes to read.
	 */
	public ProgressInputStream(InputStream in, IProgressMonitor mon, long numBytes) {
		super(in);
		this.mon = mon;
		this.numBytes = numBytes;
	}
	
	/*
	 * (non-Javadoc)
	 * @see java.io.FilterInputStream#read()
	 */
	@Override
    public int read() throws IOException {
		int res = super.read();
		updateProgress(1);
        return res;
    }

	/*
	 * (non-Javadoc)
	 * @see java.io.FilterInputStream#read(byte[])
	 */
    @Override
    public int read(byte[] b) throws IOException {
        return (int)updateProgress(super.read(b));
    }

    /*
     * (non-Javadoc)
     * @see java.io.FilterInputStream#read(byte[], int, int)
     */
    @Override
    public int read(byte[] b, int off, int len) throws IOException {
        return (int)updateProgress(super.read(b, off, len));
    }

    /*
     * (non-Javadoc)
     * @see java.io.FilterInputStream#skip(long)
     */
    @Override
    public long skip(long n) throws IOException {
        return updateProgress(super.skip(n));
    }

    /*
     * (non-Javadoc)
     * @see java.io.FilterInputStream#mark(int)
     */
    @Override
    public void mark(int readlimit) {
        throw new UnsupportedOperationException();
    }

    /*
     * (non-Javadoc)
     * @see java.io.FilterInputStream#reset()
     */
    @Override
    public void reset() throws IOException {
        throw new UnsupportedOperationException();
    }

    /*
     * (non-Javadoc)
     * @see java.io.FilterInputStream#markSupported()
     */
    @Override
    public boolean markSupported() {
        return false;
    }
    
	/*
	 * Updates the progress monitor according to how many bytes have been read
	 * and checks cancel isn't requested.
	 */
    private long updateProgress(long numBytesRead) throws IOException {
    	try {
			mon.checkCanceled();
			if (numBytesRead > 0)
	        	mon.progress((double)numBytesRead / numBytes);
		} catch (CancellationException e) {
			throw new IOException(e);
		}
        return numBytesRead;
    }

}
