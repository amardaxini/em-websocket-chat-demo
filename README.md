It is an basic app for PUB/SUB application using EventMachine and Websocket

Step
====
1. Install Dependency

  `bundle install`
  
2. Start creating your database 

  `rake db:create && rake db:migrate`

3. Start Rails server 

  `rails server`
  
4. Start Chat Server
 
  `./script/em_chat`
  

NOTE
====

  Default port where em_chat run is `8080`  if you ever happen to change this please do make the necesary changes in
  public/javascripts/em_chat.js

OTHERS
======

    The app was developed for understanding html5 websocket and event machine.
    In the process we came with some hack to fix some known issue like page refresh 
    
    Working

    Once the User is logged in the a default web-socket connection is establish 
    This connection only need is to notify users 
    
    If the users wish initiate a channel he/she can do this by clicking the list of active users

    We started with this application with aim of understand html5 web-socket and we havent tested this on any of our
    live project so we are unsure of how much reliable the application would be on heavy load
    
    If you every happen to test this on your live production site . We would love to hear on that
    
Credits
=======

   [Amar Daxini](https://github/amardaxini)
   
   [Viren Negi](https://github/meetme2meat) 







