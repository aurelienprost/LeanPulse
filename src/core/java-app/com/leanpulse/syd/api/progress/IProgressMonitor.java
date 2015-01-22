/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api.progress;

import java.util.concurrent.CancellationException;

/**
 * Common interface used by SyD to report progress.
 * <p>
 * The <code>IProgressMonitor</code> interface is implemented by objects that
 * monitor the progress of an activity; the methods in this interface are
 * invoked by code that performs the activity.
 * <p>
 * All activity is broken down into a linear sequence of tasks against which
 * progress is reported. When a task begins, a
 * <code>start(String, double)</code> notification is reported, followed by any
 * number and mixture of progress reports (<code>progress()</code>) and subtask
 * notifications (<code>createSubProgress(String, double)</code>). When the task is
 * eventually completed, a <finish>finish</code> notification is reported.
 * After the <finish>finish</code> notification, the progress monitor cannot
 * be reused; i.e., <code>start(String, double)</code> cannot be called again
 * after the call to <finish>finish</code>.
 * <p>
 * A request to cancel an operation can be signaled using the <code>requestCancel</code>
 * method. Operations taking a progress monitor are expected to poll the monitor
 * (using <code>isCanceled</code> or <code>checkCanceled</code>) periodically and abort at their earliest convenience.
 * Operation can however choose to ignore cancellation requests.
 * <p>
 * Since notification is synchronous with the activity itself, the listener
 * should provide a fast and robust implementation. If the handling of
 * notifications would involve blocking operations, or operations which might
 * throw uncaught exceptions, the notifications should be queued, and the actual
 * processing deferred (or perhaps delegated to a separate thread).
 * <p>
 * Clients may implement this interface.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public interface IProgressMonitor {
	
	/**
	 * Notifies that the main task is starting.
	 * <p>
	 * This must only be called once on a given progress monitor instance.
	 * 
	 * @param description
	 *            The description of the main task.
	 * @param totalWork
	 *            The total number of work units into which the main task is
	 *            been subdivided.
	 */
	void start(String description, double totalWork);
	
	/**
	 * Notifies that a given number of work unit of the main task has been
	 * completed.
	 * <p>
	 * Note that this amount represents an installment, as opposed to a
	 * cumulative amount of work done to date.
	 * 
	 * @param work
	 *            A non-negative number of work units just completed.
	 */
	void progress(double work);
	
	/**
	 * Utility method to only update the description of the running task.
	 * <p>
	 * This method behaves exactly as if it simply performs the call
	 * <code>progress(description, 0.0)</code>
	 * 
	 * @param description
	 *            The updated description.
	 */
	void progress(String description);
	
	/**
	 * Notifies that a given number of work unit of the main task has been
	 * completed and updates the description.
	 * <p>
	 * Note that this amount represents an installment, as opposed to a
	 * cumulative amount of work done to date.
	 * 
	 * @param description
	 *            The updated description.
	 * @param work
	 *            A non-negative number of work units just completed.
	 */
	void progress(String description, double work);
	
	/**
	 * Requests to cancel the current operation.
	 * 
	 * @see #isCanceled()
	 * @see #checkCanceled()
	 */
	void requestCancel();
	
	/**
	 * Throws an exception if cancellation has been requested.
	 * <p>
	 * Long-running operations should poll to see if cancellation has been
	 * requested.
	 * 
	 * @throws CancellationException
	 *             If cancellation has been requested.
	 * 
	 * @see #isCanceled()
	 */
	void checkCanceled() throws CancellationException;
	
	/**
	 * Returns whether the current operation is running.
	 * <p>
	 * Note that the operation may still be running for some time after
	 * cancellation has been requested but hasn't been yet taken into account.
	 * 
	 * @return <code>true</code> if the current operation has been started and
	 *         isn't finished yet, <code>false</code> otherwise.
	 */
	boolean isRunning();
	
	/**
	 * Returns whether cancellation of current operation has been requested.
	 * <p>
	 * Long-running operations should poll to see if cancellation has been
	 * requested.
	 * 
	 * @return <code>true</code> if cancellation has been requested,
	 *         <code>false</code> otherwise.
	 * 
	 * @see #checkCanceled()
	 */
	boolean isCanceled();
	
	/**
	 * Returns whether the current operation is finished.
	 * 
	 * @return <code>true</code> if the current operation is finished,
	 *         <code>false</code> otherwise.
	 */
	boolean isFinished();
	
	/**
	 * Notifies that the current operation finished.
	 * <p>
	 * This means that either the main task is completed or the user canceled
	 * it.
	 * 
	 * @param description
	 *            A description to indicate the current operation finished.
	 */
	void finish(String description);
	
	/**
	 * Notifies that the current operation finished with an error.
	 * 
	 * @param description
	 *            A description to indicate the current operation finished with
	 *            an error.
	 * @param ex
	 *            The exception that made the current operation failed.
	 */
	void finish(String description, Exception ex);
	
	/**
	 * Returns whether the current operation finished with an error.
	 * 
	 * @return <code>true</code> if the current operation finished with an
	 *         error, <code>false</code> otherwise.
	 */
	boolean hasError();
	
	/**
	 * Causes the current thread to wait until the operation finished.
	 * <p>
	 * In other words, the current thread will wait until another thread invokes
	 * {@link #finish(String)} or {@link #finish(String, Exception)}.
	 * 
	 * @throws InterruptedException
	 *             If any thread interrupted the current thread before or while
	 *             the current thread was waiting for a notification.
	 */
	void waitFinish() throws InterruptedException;
	
	/**
	 * Creates a sub-progress monitor reporting the progress of a sub-task of
	 * the main operation.
	 * <p>
	 * Several sub-progress monitors can be created for the same operation in
	 * order to report the progress of several parallel running tasks.
	 * 
	 * @param name
	 *            The name of the sub-progress monitor.
	 * @param parentWorkUnits
	 *            The number of parent work units consumed by the sub-task.
	 * @return The created sub-progress monitor.
	 */
	IProgressMonitor createSubProgress(String name, double parentWorkUnits);
	
	/**
	 * Causes the current thread to wait until all the sub-progress monitor are
	 * finished.
	 * 
	 * @throws InterruptedException
	 *             If any thread interrupted the current thread before or while
	 *             the current thread was waiting for a notification.
	 */
	void waitSubProgessFinish() throws InterruptedException;

}
