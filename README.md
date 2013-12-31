## I am no longer supporting this project or actively using it.

![](http://i.imgur.com/w3hXT.png)

What is LandingPad.rb
----
**LandingPad.rb** is a simple "landing page" application that takes just a few minutes to setup. It lets you quickly put up a page to collect email addresses or Twitter users for when you are ready to launch your app/product/whatever.

LandingPad.rb can be hosted on Heroku and use MongoHQ to store the contacts -- both of which have free plans that will work fine. Buy a domain and point it to your LandingPad.rb app and you are good to go!

Google Analytics are supported so you can track views and conversion rates for signing up.

How to use LandingPad.rb
----
1. Setup an account on [Heroku](heroku.com) (you can use the free account)  
Instructions: [http://devcenter.heroku.com/articles/quickstart]()  
Make sure you have the pre-reqs: [http://devcenter.heroku.com/articles/quickstart#prerequisites]()  

1. Extract **LandingPad.rb** into a folder

1. Navigate to that folder.

	`$> ls` should show "`config.ru  landingpad.rb public/  views/`" if you are in the right folder

1. Run `bundle install` to install required gems.  (You must have [Bundler](http://gembundler.com/) installed-- run `gem install bundler` to install.)

1. Open `landingpad.rb` in a text editor.  You should see a `configure` block where you can enter the details for your landing page (such as your site's name, a summary, colors, etc).

	This is also where you set the admin username and password for accessing your stored contacts -- **PLEASE CHANGE THIS!**

	You can also set your Google Analytics tracking id in this file if you have an account.

1. Once you have edited `landingpad.rb` to add your app's settings, run the following commands from your project folder:

         git init
         git add .
         git commit -m "setting up landing page"

1. Now create your Heroku app by running from your project folder:

         heroku create
         heroku addons:add mongohq:sandbox

1. Now run `git push heroku master` to push the code to your Heroku app.  Once it's finished, run `heroku open` to launch a browser and go to your app.  

	You should see a landing page and be able to enter in an email address or Twitter account name.  To view the contact information stored in your app, navigate to **http://your-heroku-machine-name.heroku.com/contacts**.  You will need to enter the username and password that you setup in Step 4.  

	You should see a table listing the name, type and referal URL for anyone that has signed up for your app.

1.  You will probably want a custom domain, following the instructions here [http://devcenter.heroku.com/articles/custom-domains]() to setup your domain to point to your brand-new landing page.

Uhh...something broke
----
You can try to debug your page on your local machine by installing the correct gems with Bundler and running the app using `rackup config.ru -p 3456`.  You can get to it by opening a browser and going to `localhost:3456`.  

Make sure you have all of your settings correct in `landingpad.rb`.

If you make any changes to the code, make sure to do a `git add/git commit` and push the changes to heroku.

It looks good, but I want it to be blue
---
You can modify any of the code, html, css and javascript to customize your page.  Just remember to push any changes to Heroku so your live page will be updated.
         


