# 88 Miles Command Line Application

88 Miles is simple time tracking for freelance developers, designers and copywriters. This gem allows you to access you account from your command line.

To use this gem, you will need an 88 Miles account. You can [register here](http://88miles.net)

## Installation

    gem install 88miles

## Get started

First, you will need to give the gem access to 88 Miles. This is done via OAuth, so you don't need to ever store your login or password.

To setup the link:

    88miles setup

If you on a computer has a default browser, it will open a browser window asking you to login, and approve access to the application.

Once authentication has happened, you will be redirected to a confirmation window. Cut and paste the URL from this window in to the console that you started the process.

## Linking a Project to a directory

The command line application links directories with projects in 88 Miles. To setup the link, run

    88miles init [path/to/directory]

You will be presented with a list of projects to select from. Select a project, and the link is complete.

## Punching in

Once you have linked a project, you can punch in by:

    88miles start

If you want to select an activity:

    88miles start -a

You will be presented with a list of activities from which you can select from

## Punching out

To punch out of the linked project

    88miles stop -n "Any notes to associate with shift"

## View the current status of the project

You can see how much time you have clocked against a project by:

    88miles status

If you want to have it automatically update, you can leave it in the foreground

    88miles status -f

Hit Ctrl-C to exit foreground mode.

## List all shifts

If you want to view a list of all the shifts clocked against the linked project:

    88miles log

To format it in a nice table view:

    88miles log -t

## Update the local cache

To speed things up, your company, project and staff list is cached locally. If you modify any of these things on the website, you'll need to re-sync the cache by:

    88miles sync

## Thank you

A hat tip to domm for the inspiration: http://timetracker.plix.at/

## Copyright

Copyright (c) 2013 [MadPilot Productions](http://www.madpilot.com.au/). See LICENSE.txt for further details.
