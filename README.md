# Robust Calendar Service Deployment with Baikal / SabreDAV in 10 Minutes 

Baikal / SabreDAV robust calendar and address book server with scheduling and
email notifications.

Calendar services are an organization's lifeblood next to email.  This guide
shows how to ready and deploy a robust, enterprise-class calendar service
compliant with all vendor and Internet calendaring, scheduling, and messaging
standards --  enable CalDAV and CardDAV for OS X, iOS, Android, Windows, and
Linux calendar clients in 10 minutes or less.  It leverages the power of
Baïkal/SabreDAV, Postfix, Docker, and Linux.

## About this implementation

* This is a complete deployment set up, ready for production systems
* There are lots of Baïkal and other calendar server images out there, but all
  the ones tested in preparing this deployment were missing important features
  like scheduling, message delivery, etc.
* It works with the latest stable SabreDAV/Baïkal versions
* iOS, OS X, Android, Thunderbird Lightning, and Windows calendar, tasks, and
  address book clients work well with this set up
* It supports full scheduling and messaging to event participants and resources
  across any calendaring service (Baïkal to Google Calendar or Exchange)

## Implementation

The complete implementation is described in detail at the
[pr3d4t0r blog](https://ciurana.eu/entry/robust-calendar-service-deployment-howto).

