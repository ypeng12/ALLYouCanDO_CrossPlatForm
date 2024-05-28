# CMSC436 Project Proposal: Watchlist

## Project Team 22

* Chen Ye 
* Erik Lin
* Yuliang Peng

## App Description

This app is an errands app that will allow users to post tasks selected from various categories. 
It will cater to people who need tasks done and are willing to pay others to do them. 
Additionally, users can accept tasks to make part-time money if the price is suitable for them and they know how to complete the task

## Minimal Goals

The app will contain a list of users section and worker section, 
with an interface that allows the user to post or accept tasks. For each each, the user will be able to select: 

 *  What tasks need people to complete and post on the task list
 * Task detail
   * Task Type
   * Price 
   * Time 	
   * Location 

 * In the worker section, workers can accept the task, and the task will disappear on the task board if the task is accepted by any worker. 
 * The user who posts a task if accepted by any worker, the user will have notification
 * Use the database shown in class to record tasks
 * Need the user check the task was finished or not, if finished the all done (if the task not finished the task will reappear)

## Stretch Goals

We have identified the following stretch goals:

 * Integrate an SQL database hosted on AWS that has a task and account schema.
 * Camera 
   * When a tasker finishes a task take a picture as evidence 
 * Allow users to create accounts
   * Sign Up/Login Page



## Project Timeline

### Milestone 1

 * Build the foundation (as in the user interface) of the app
   * Dummy login homepage
   * Create a request tab (for consumers)
  
      * Allow users to attach images
      * Task Types (Classify enums)
      * Price input
      * Deadline for Request (will do nothing for now/will automatically delete from DB later)
      * Location (String for now)

 * Create a dummy list of available requests (for suppliers)
 * Create a dummy list of requests the supplier has taken
 * History page


### Milestone 2

 * Finish the functionality of the app
   * The ability to enter information about a new task
   * A tasker can pick up a task 
 * Animation 
   * For example, when the user login an animation will begin, or when the task list gets updated it’ll have an animation  
 
 


### Milestone 3

 * Start stretch goals
 * When the worker finished and user check that’s done then disappear the task
 * History page to show previous completed transactions

 

### Final submission

Stretch goals completed, project submitted, and a demonstration
scheduled.
